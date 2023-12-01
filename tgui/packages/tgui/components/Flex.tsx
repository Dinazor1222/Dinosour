/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { BoxProps, computeBoxClassName, computeBoxProps, unit } from './Box';

export type FlexProps = BoxProps &
  Partial<{
    direction: string | boolean;
    wrap: string | boolean;
    align: string | boolean;
    justify: string | boolean;
    inline: boolean;
    scrollable: boolean;
    style: Partial<HTMLDivElement['style']>;
  }>;

export const computeFlexClassName = (props: FlexProps) => {
  return classes([
    'Flex',
    props.inline && 'Flex--inline',
    computeBoxClassName(props),
  ]);
};

export const computeFlexProps = (props: FlexProps) => {
  const { className, direction, wrap, align, justify, inline, ...rest } = props;
  return computeBoxProps({
    style: {
      ...rest.style,
      'flex-direction': direction,
      'flex-wrap': wrap === true ? 'wrap' : wrap,
      'align-items': align,
      'justify-content': justify,
    },
    ...rest,
  });
};

export const Flex = (props) => {
  const { className, ...rest } = props;
  return (
    <div
      className={classes([className, computeFlexClassName(rest)])}
      {...computeFlexProps(rest)}
    />
  );
};

Flex.defaultHooks = pureComponentHooks;

export type FlexItemProps = BoxProps &
  Partial<{
    grow: number | boolean;
    order: number;
    shrink: number | boolean;
    basis: string | number;
    align: string | boolean;
    style: Partial<HTMLDivElement['style']>;
  }>;

export const computeFlexItemClassName = (props: FlexItemProps) => {
  return classes(['Flex__item', computeBoxClassName(props)]);
};

export const computeFlexItemProps = (props: FlexItemProps) => {
  const { className, style, grow, order, shrink, basis, align, ...rest } =
    props;

  const computedBasis =
    basis ??
    // IE11: Set basis to specified width if it's known, which fixes certain
    // bugs when rendering tables inside the flex.
    props.width ??
    // If grow is used, basis should be set to 0 to be consistent with
    // flex css shorthand `flex: 1`.
    (grow !== undefined ? 0 : undefined);
  return computeBoxProps({
    style: {
      ...style,
      'flex-grow': grow !== undefined && Number(grow),
      'flex-shrink': shrink !== undefined && Number(shrink),
      'flex-basis': unit(computedBasis),
      'order': order,
      'align-self': align,
    },
    ...rest,
  });
};

const FlexItem = (props) => {
  const { className, ...rest } = props;
  return (
    <div
      className={classes([className, computeFlexItemClassName(props)])}
      {...computeFlexItemProps(rest)}
    />
  );
};

FlexItem.defaultHooks = pureComponentHooks;

Flex.Item = FlexItem;

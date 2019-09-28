import { classes } from 'react-tools';
import { Box } from './Box';

export const computeFlexProps = props => {
  const {
    className,
    direction,
    wrap,
    align,
    justify,
    ...rest
  } = props;
  return {
    className: classes('Flex', className),
    style: {
      ...rest.style,
      'flex-direction': direction,
      'flex-wrap': wrap,
      'align-items': align,
      'justify-content': justify,
    },
    ...rest,
  };
};

export const Flex = props => (
  <Box {...computeFlexProps(props)} />
);

export const computeFlexItemProps = props => {
  const {
    className,
    grow,
    order,
    align,
    ...rest
  } = props;
  return {
    className: classes('Flex__item', className),
    style: {
      ...rest.style,
      'flex-grow': grow,
      'order': order,
      'align-self': align,
    },
    ...rest,
  };
};

export const FlexItem = props => (
  <Box {...computeFlexItemProps(props)} />
);

Flex.Item = FlexItem;

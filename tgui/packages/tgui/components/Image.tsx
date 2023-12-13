import { ReactNode } from 'react';
import { Box, BoxProps } from './Box';
import { Tooltip } from './Tooltip';

type Props = {
  tooltip?: ReactNode;
} & IconUnion &
  BoxProps;

type IconUnion =
  | {
      src: string;
    }
  | {
      className: string;
    };

/** Image component. Use this instead of Box as="img". */
export const Image = (props: Props) => {
  const { src, tooltip, ...rest } = props;

  let content = (
    <Box {...rest}>
      <img className="tgui__image" src={src} />
    </Box>
  );

  if (tooltip) {
    content = <Tooltip content={tooltip}>{content}</Tooltip>;
  }

  return content;
};

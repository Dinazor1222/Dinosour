import { classes } from 'react-tools';

export const Section = props => {
  const { title, level = 1, buttons, children } = props;
  return (
    <div
      className={classes([
        'Section',
        'Section--level--' + level,
      ])}>
      <div className="Section__title">
        <span className="Section__titleText">
          {title}
        </span>
        <div className="Section__buttons">
          {buttons}
        </div>
      </div>
      <div className="Section__content">
        {children}
      </div>
    </div>
  );
};

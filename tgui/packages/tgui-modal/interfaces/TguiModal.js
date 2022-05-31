import { Component } from 'inferno';
import { classes } from 'common/react';
import { KEY_TAB } from 'common/keycodes';
import { TextArea } from 'tgui/components';

const CHANNELS = ['say', 'radio', 'me', 'ooc'];

/** Window sizes in pixels */
const SIZE = {
  small: 58,
  medium: 85,
  large: 110,
};

/** Returns modular css classes*/
const getCss = (element, channel, size) =>
  classes([element, `${element}-${CHANNELS[channel]}`, `${element}-${size}`]);

/**
 * Primary class for the TGUI modal.
 *
 * Props:
 *  - channel: The channel (thereby, color) to display the modal for.
 *  - maxLength: The maximum length of the message.
 */
export class TguiModal extends Component {
  constructor(props) {
    super(props);
    this.maxLength = props.maxLength || 1024;
    this.state = {
      buttonContent: '>',
      channel: CHANNELS.indexOf(props.channel) || 0,
      hovering: false,
      size: SIZE.small,
    };
  }
  /** Mouse leaves the button */
  handleBlur = () => {
    this.hovering = false;
    this.setState({ buttonContent: `>` });
  };
  /** User clicks the channel button. */
  handleClick = () => {
    this.incrementChannel();
  };
  /** User presses enter. Closes if no value. */
  handleEnter = (_, value) => {
    const { channel } = this.state;
    const { maxLength } = this.maxLength;
    this.setSize(0);
    if (!value || value.length > maxLength) {
      Byond.sendMessage('close');
    } else {
      Byond.sendMessage('entry', {
        channel: CHANNELS[channel],
        entry: value,
      });
    }
  };
  /** User presses escape, closes the window */
  handleEscape = () => {
    this.setSize(0);
    Byond.sendMessage('close');
  };
  /** Mouse over button. Changes button to channel name. */
  handleFocus = () => {
    const { channel } = this.state;
    this.setState({
      buttonContent: CHANNELS[channel].slice(0, 1).toUpperCase(),
      hovering: true,
    });
  };
  /** Grabs the TAB key to change channels. */
  handleKeyDown = (event, value) => {
    if (e.keyCode === KEY_TAB) {
      this.incrementChannel();
      event.preventDefault();
    }
    this.setSize(value);
  };
  /**
   * Increments the channel or resets to the beginning of the list.
   * If a user is hovering over the button, the channel is changed.
   */
  incrementChannel() {
    const { channel, hovering } = this.state;
    if (channel === CHANNELS.length - 1) {
      this.setState({
        buttonContent: !hovering ? '>' : CHANNELS[0].slice(0, 1).toUpperCase(),
        channel: 0,
      });
    } else {
      this.setState({
        buttonContent: !hovering
          ? '>'
          : CHANNELS[channel + 1].slice(0, 1).toUpperCase(),
        channel: channel + 1,
      });
    }
  }
  /**  Adjusts window sized based on target value */
  setSize = (value) => {
    if (value.length > 56) {
      this.setState({ size: SIZE.large });
    } else if (value.length > 22) {
      this.setState({ size: SIZE.medium });
    } else {
      this.setState({ size: SIZE.small });
    }
    this.setWindow();
  };
  /**
   * Modifies the window size.
   * This would be included in setSize but state is async
   */
  setWindow = () => {
    const { size } = this.state;
    Byond.winset(Byond.windowId, { size: `333x${size}` });
    Byond.winset('tgui_modal_browser', { size: `333x${size}` });
  };

  render() {
    const {
      handleBlur,
      handleClick,
      handleEnter,
      handleEscape,
      handleFocus,
      handleInput,
      handleKeyDown,
      props: { maxLength },
    } = this;
    const { buttonContent, channel, size } = this.state;
    return (
      <div className={getCss('window', channel, size)}>
        {size < SIZE.medium && (
          <button
            className={getCss('button', channel)}
            onclick={handleClick}
            onmouseenter={handleFocus}
            onmouseleave={handleBlur}
            type="submit">
            {buttonContent}
          </button>
        )}
        <TextArea
          autoFocus
          className={getCss('input', channel, size)}
          dontUseTabForIndent
          maxLength={maxLength}
          onEnter={handleEnter}
          onEscape={handleEscape}
          onInput={handleInput}
          onKeyDown={handleKeyDown}
          selfClear
        />
      </div>
    );
  }
}

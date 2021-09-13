import { classes } from "common/react";
import { sendAct, useBackend, useLocalState } from "../../backend";
import { Autofocus, Box, Button, ByondUi, Dropdown, FitText, Flex, Icon, Input, LabeledList, NumberInput, Popper, Stack, TrackOutsideClicks } from "../../components";
import { createSetPreference, PreferencesMenuData, RandomSetting, ServerSpeciesData } from "./data";
import { exhaustiveCheck } from "common/exhaustive";

export const RandomizationButton = (props: {
  dropdownProps?: Record<string, unknown>,
  setValue: (newValue: RandomSetting) => void,
  value: RandomSetting,
}) => {
  const {
    dropdownProps = {},
    setValue,
    value,
  } = props;

  let color;

  switch (value) {
    case RandomSetting.AntagOnly:
      color = "orange";
      break;
    case RandomSetting.Disabled:
      color = "red";
      break;
    case RandomSetting.Enabled:
      color = "green";
      break;
    default:
      exhaustiveCheck(value);
  }

  return (
    <Dropdown
      backgroundColor={color}
      {...dropdownProps}
      clipSelectedText={false}
      displayText={(
        <Icon
          name="dice-d20"
          mr="-0.25em"
        />
      )}
      options={[
        {
          displayText: "Do not randomize",
          value: RandomSetting.Disabled,
        },

        {
          displayText: "Always randomize",
          value: RandomSetting.Enabled,
        },

        {
          displayText: "Randomize when antagonist",
          value: RandomSetting.AntagOnly,
        },
      ]}
      nochevron
      onSelected={setValue}
      width="auto"
    />
  );
};

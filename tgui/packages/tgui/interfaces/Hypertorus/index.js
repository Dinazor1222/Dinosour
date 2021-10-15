import { useBackend } from 'tgui/backend';
import { Button, Collapsible, Section, Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';
import { HypertorusSecondaryControls, HypertorusWasteRemove } from './Controls';
import { HypertorusGases } from './Gases';
import { ActFixed } from './helpers';
import { HypertorusParameters } from './Parameters';
import { HypertorusRecipes } from './Recipes';
import { HypertorusTemperatures } from './Temperatures';

const HypertorusMainControls = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section title="Startup">
      <Stack>
        <Stack.Item color="label">
          {'Start power: '}
          <Button
            disabled={data.power_level > 0}
            icon={data.start_power ? 'power-off' : 'times'}
            content={data.start_power ? 'On' : 'Off'}
            selected={data.start_power}
            onClick={ActFixed(act, 'start_power')} />
        </Stack.Item>
        <Stack.Item color="label">
          {'Start cooling: '}
          <Button
            disabled={data.start_fuel === 1
                || data.start_moderator === 1
                || data.start_power === 0
                || (data.start_cooling && data.power_level > 0)}
            icon={data.start_cooling ? 'power-off' : 'times'}
            content={data.start_cooling ? 'On' : 'Off'}
            selected={data.start_cooling}
            onClick={ActFixed(act, 'start_cooling')} />
        </Stack.Item>
      </Stack>
      <Collapsible title="Recipe selection">
        <HypertorusRecipes
          baseMaximumTemperature={data.base_max_temperature}
          enableRecipeSelection={data.power_level === 0}
          onRecipe={id => act('fuel', { mode: id })}
          selectableFuels={data.selectable_fuel}
          selectedFuelID={data.selected}
        />
      </Collapsible>
    </Section>
  );
};

const HypertorusLayout = () => {
  return (
    <span class="hypertorus-layout">
      <HypertorusMainControls />
      <Stack>
        <Stack.Item grow>
          <HypertorusGases />
        </Stack.Item>
        <Stack.Item>
          <HypertorusTemperatures />
        </Stack.Item>
      </Stack>
      <HypertorusParameters />
      <HypertorusSecondaryControls />
      <HypertorusWasteRemove />
    </span>
  );
};

export const Hypertorus = (props, context) => {
  return (
    <Window
      title="Hypertorus Fusion Reactor control panel"
      width={850}
      height={980}>
      <Window.Content scrollable>
        <HypertorusLayout />
      </Window.Content>
    </Window>
  );
};

import { act } from 'byond';
import { Fragment } from 'inferno';
import { toTitleCase } from 'string-tools';
import { AnimatedNumber, Box, Button, Icon, LabeledList, ProgressBar, Section } from '../components';
import { fixed } from '../math';

export const ChemDispenser = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const recording = !!data.recordingRecipe;
  // TODO: Change how this piece of shit is built on server side
  // It has to be a list, not a fucking OBJECT!
  const recipes = Object.keys(data.recipes)
    .map(name => ({
      name,
      contents: data.recipes[name],
    }));
  const beakerTransferAmounts = data.beakerTransferAmounts || [];
  const beakerContents = recording
    && Object.keys(data.recordingRecipe)
      .map(id => ({
        id,
        name: toTitleCase(id.replace(/_/, ' ')),
        volume: data.recordingRecipe[id],
      }))
    || data.beakerContents
    || [];
  return (
    <Fragment>
      <Section
        title="Status"
        buttons={recording && (
          <Box inline mx={1} color="pale-red">
            <Icon name="circle" mr={1} />
            Recording
          </Box>
        )}>
        <LabeledList>
          <LabeledList.Item label="Energy">
            <ProgressBar
              value={data.energy / data.maxEnergy}
              content={fixed(data.energy) + ' units'} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Recipes"
        buttons={(
          <Fragment>
            {!recording && (
              <Box inline mx={1}>
                <Button
                  color="transparent"
                  content="Clear recipes"
                  onClick={() => act(ref, 'clear_recipes')} />
              </Box>
            )}
            {!recording && (
              <Button
                icon="circle"
                disabled={!data.isBeakerLoaded}
                content="Record"
                onClick={() => act(ref, 'record_recipe')} />
            )}
            {recording && (
              <Button
                icon="ban"
                color="transparent"
                content="Discard"
                onClick={() => act(ref, 'cancel_recording')} />
            )}
            {recording && (
              <Button
                icon="floppy-o"
                color="green"
                content="Save"
                onClick={() => act(ref, 'save_recording')} />
            )}
          </Fragment>
        )}>
        {recipes.map(recipe => (
          <Button key={recipe.name}
            icon="tint"
            style={{
              'width': '130px',
              'line-height': '21px',
            }}
            content={recipe.name}
            onClick={() => act(ref, 'dispense_recipe', {
              recipe: recipe.name,
            })} />
        ))}
        {recipes.length === 0 && (
          <Box color="light-gray">
            No recipes.
          </Box>
        )}
      </Section>
      <Section
        title="Dispense"
        buttons={(
          beakerTransferAmounts.map(amount => (
            <Button key={amount}
              icon="plus"
              selected={amount === data.amount}
              disabled={recording}
              content={amount}
              onClick={() => act(ref, 'amount', {
                target: amount,
              })} />
          ))
        )}>
        <Box mr={-1}>
          {data.chemicals.map(chemical => (
            <Button key={chemical.id}
              icon="tint"
              style={{
                'width': '130px',
                'line-height': '21px',
              }}
              content={chemical.title}
              onClick={() => act(ref, 'dispense', {
                reagent: chemical.id,
              })} />
          ))}
        </Box>
      </Section>
      <Section
        title="Beaker"
        buttons={(
          beakerTransferAmounts.map(amount => (
            <Button key={amount}
              icon="minus"
              disabled={recording}
              content={amount}
              onClick={() => act(ref, 'remove', { amount })} />
          ))
        )}>
        <LabeledList>
          <LabeledList.Item
            label="Beaker"
            buttons={!!data.isBeakerLoaded && (
              <Button
                icon="eject"
                content="Eject"
                disabled={!data.isBeakerLoaded}
                onClick={() => act(ref, 'eject')} />
            )}>
            {recording
              && 'Virtual beaker'
              || data.isBeakerLoaded
                && (
                  <Fragment>
                    <AnimatedNumber
                      value={data.beakerCurrentVolume}
                      format={value => Math.round(value)} />
                    /{data.beakerMaxVolume} units
                  </Fragment>
                )
              || 'No beaker'}
          </LabeledList.Item>
          <LabeledList.Item
            label="Contents">
            <Box color="highlight">
              {(!data.isBeakerLoaded && !recording) && 'N/A'
                || beakerContents.length === 0 && 'Nothing'}
            </Box>
            {beakerContents.map(chemical => (
              <Box
                key={chemical.name}
                color="highlight">
                <AnimatedNumber
                  value={chemical.volume}
                  format={value => fixed(value, 2)} />
                {' '}
                units of {chemical.name}
              </Box>
            ))}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};

import { BooleanLike } from '../../common/react';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Icon, Input, Stack, LabeledList, Box, NoticeBox } from '../components';
import { Window } from '../layouts';

type typePath = string;

type CellularEmporiumContext = {
  abilities: Ability[];
  can_readapt: BooleanLike;
  genetic_points_count: number;
  owned_abilities: typePath[];
  absorb_count: number;
  dna_count: number;
};

type Ability = {
  name: string;
  desc: string;
  helptext: string;
  path: typePath;
  genetic_point_required: number; // Checks against genetic_points_count
  absorbs_required: number; // Checks against absorb_count
  dna_required: number; // Checks against dna_count
};

export const CellularEmporium = (props) => {
  const { act, data } = useBackend<CellularEmporiumContext>();
  const [searchAbilities, setSearchAbilities] = useLocalState(
    'searchAbilities',
    ''
  );

  const { can_readapt, genetic_points_count } = data;
  return (
    <Window width={900} height={480}>
      <Window.Content>
        <Section
          fill
          scrollable
          title={'Genetic Points'}
          buttons={
            <Stack>
              <Stack.Item fontSize="16px">
                {genetic_points_count && genetic_points_count}{' '}
                <Icon name="dna" color="#DD66DD" />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="undo"
                  content="Readapt"
                  color="good"
                  disabled={!can_readapt}
                  tooltip={
                    can_readapt
                      ? 'We readapt, un-evolving all evolved abilities \
                    and refunding our genetic points.'
                      : 'We cannot readapt until we absorb more DNA.'
                  }
                  onClick={() => act('readapt')}
                />
              </Stack.Item>
              <Stack.Item>
                <Input
                  width="200px"
                  onInput={(event) => setSearchAbilities(event.target.value)}
                  placeholder="Search Abilities..."
                  value={searchAbilities}
                />
              </Stack.Item>
            </Stack>
          }>
          <AbilityList />
        </Section>
      </Window.Content>
    </Window>
  );
};

const AbilityList = (props) => {
  const { act, data } = useBackend<CellularEmporiumContext>();
  const [searchAbilities] = useLocalState('searchAbilities', '');
  const {
    abilities,
    owned_abilities,
    genetic_points_count,
    absorb_count,
    dna_count,
  } = data;

  const filteredAbilities =
    searchAbilities.length <= 1
      ? abilities
      : abilities.filter((ability) => {
        return (
          ability.name.toLowerCase().includes(searchAbilities.toLowerCase()) ||
          ability.desc.toLowerCase().includes(searchAbilities.toLowerCase()) ||
          ability.helptext.toLowerCase().includes(searchAbilities.toLowerCase())
        );
      });

  if (filteredAbilities.length === 0) {
    return (
      <NoticeBox>
        {abilities.length === 0
          ? 'No abilities available to purchase. \
        This is in error, contact your local hivemind today.'
          : 'No abilities found.'}
      </NoticeBox>
    );
  } else {
    return (
      <LabeledList>
        {filteredAbilities.map((ability) => (
          <LabeledList.Item
            key={ability.name}
            className="candystripe"
            label={ability.name}
            buttons={
              <Stack>
                <Stack.Item>{ability.genetic_point_required}</Stack.Item>
                <Stack.Item>
                  <Icon
                    name="dna"
                    color={
                      owned_abilities.includes(ability.path)
                        ? '#DD66DD'
                        : 'gray'
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content={'Evolve'}
                    disabled={
                      owned_abilities.includes(ability.path) ||
                      ability.genetic_point_required > genetic_points_count ||
                      ability.absorbs_required > absorb_count ||
                      ability.dna_required > dna_count
                    }
                    onClick={() =>
                      act('evolve', {
                        path: ability.path,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            }>
            {ability.desc}
            <Box color="good">{ability.helptext}</Box>
          </LabeledList.Item>
        ))}
      </LabeledList>
    );
  }
};

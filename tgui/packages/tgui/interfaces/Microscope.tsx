import { BooleanLike } from 'common/react';
import { classes } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Icon,
  NoticeBox,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Data = {
  has_dish: BooleanLike;
  cell_lines: CellLine[];
};

type CellLine = {
  type: string;
  name: string;
  desc: string;
  icon: string;
  consumption_rate: number;
  growth_rate: number;
  suspectibility: number;
  requireds: Reagent[];
  supplementaries: Reagent[];
  suppressives: Reagent[];
};

type Reagent = {
  [key: string]: number;
};

export const Microscope = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_dish, cell_lines = [] } = data;

  return (
    <Window width={620} height={620}>
      <Window.Content scrollable>
        <Section
          title={has_dish ? 'Petri Dish Sample' : 'No Petri Dish'}
          buttons={
            !!has_dish && (
              <Button
                icon="eject"
                disabled={!has_dish}
                onClick={() => act('eject_petridish')}
              >
                Take Dish
              </Button>
            )
          }
        >
          <CellList cell_lines={cell_lines} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const CellList = (props) => {
  const { cell_lines } = props;
  if (!cell_lines.length) {
    return <NoticeBox>No micro-organisms found</NoticeBox>;
  }

  return cell_lines.map((cell_line) => {
    return cell_line.type !== 'virus' ? (
      <Stack key={cell_line.desc} mt={2}>
        <Stack.Item>
          <Box
            m={'16px'}
            style={{
              transform: 'scale(2)',
            }}
            className={classes(['cell_line32x32', cell_line.icon])}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Section
            title={cell_line.desc}
            buttons={
              <Button
                color="transparent"
                icon="circle-question"
                tooltip="Put the sample into a Growing Vat and pour the required reagents."
              />
            }
          >
            <Box my={1}>
              Consume {cell_line.consumption_rate} units of every nutrient per
              second to grow by {cell_line.growth_rate}%.
            </Box>
            {cell_line.suspectibility > 0 && (
              <Box my={1}>
                Reduced by {cell_line.suspectibility}% when infected with
                viruses.
              </Box>
            )}
            <Stack fill>
              <Stack.Item grow>
                <GroupTitle title="Required Reagents" />
                {Object.keys(cell_line.requireds).map((reagent) => (
                  <Button fluid key={reagent}>
                    {reagent}
                  </Button>
                ))}
              </Stack.Item>
              <Stack.Item grow>
                <GroupTitle title="Supplements" />
                {Object.keys(cell_line.supplementaries).map((reagent) => (
                  <Button
                    fluid
                    color="good"
                    key={reagent}
                    tooltip={
                      '+' + cell_line.supplementaries[reagent] + '% growth/sec.'
                    }
                  >
                    {reagent}
                  </Button>
                ))}
              </Stack.Item>
              <Stack.Item grow>
                <GroupTitle title="Supressives" />
                {Object.keys(cell_line.suppressives).map((reagent) => (
                  <Button
                    fluid
                    color="bad"
                    key={reagent}
                    tooltip={cell_line.suppressives[reagent] + '% growth/sec.'}
                  >
                    {reagent}
                  </Button>
                ))}
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    ) : (
      <Stack key={cell_line.desc} mt={2}>
        <Stack.Item>
          <Icon name="viruses" size={4} mr={1} />
        </Stack.Item>
        <Stack.Item grow>
          <Section title={cell_line.desc}>
            <Box my={1}>
              Reduces growth of other cell lines when not suppressed by
              Spaceacillin.
            </Box>
          </Section>
        </Stack.Item>
      </Stack>
    );
  });
};

const GroupTitle = ({ title }) => {
  return (
    <Stack my={1}>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
      <Stack.Item
        style={{
          textTransform: 'capitalize',
        }}
        color={'gray'}
      >
        {title}
      </Stack.Item>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
    </Stack>
  ) as any;
};

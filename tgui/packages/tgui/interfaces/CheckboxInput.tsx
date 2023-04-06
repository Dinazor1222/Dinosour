import { Button, Section, Stack, Table } from '../components';
import { TableCell, TableRow } from '../components/Table';
import { useBackend, useLocalState } from '../backend';

import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';
import { Window } from '../layouts';
import { decodeHtmlEntities } from 'common/string';

type Data = {
  items: string[];
  message: string;
  title: string;
  timeout: number;
};

/** Renders a list of checkboxes per items for input. */
export const CheckboxInput = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { items = [], message, timeout, title } = data;

  const [selections, setSelections] = useLocalState<string[]>(
    context,
    'selections',
    []
  );

  const selectItem = (name: string) => {
    const newSelections = selections.includes(name)
      ? selections.filter((item) => item !== name)
      : [...selections, name];

    setSelections(newSelections);
  };

  return (
    <Window title={title} width={425} height={300}>
      {!!timeout && <Loader value={timeout} />}
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section color="label" fill textAlign="center">
              {decodeHtmlEntities(message)}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              <Table>
                {items.map((item, index) => (
                  <TableRow className="candystripe" key={index}>
                    <TableCell>
                      <Button.Checkbox
                        checked={selections.includes(item)}
                        onClick={() => selectItem(item)}>
                        {item}
                      </Button.Checkbox>
                    </TableCell>
                  </TableRow>
                ))}
              </Table>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <InputButtons input={selections} />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

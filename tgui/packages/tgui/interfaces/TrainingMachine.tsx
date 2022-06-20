import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Divider, Knob, LabeledControls, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
	movespeed: number;
	range: number;
	moving: BooleanLike;
};

export const TrainingMachine = () => {
	return (
		<Window width={230} height={150} title="AURUMILL">
			<Window.Content>
				<Section fill title="Training Machine">
					<TrainingControls />
				</Section>
			</Window.Content>
		</Window>
	);
};

/** Creates a labeledlist of controls */
const TrainingControls = (_, context) => {
	const { act, data } = useBackend<Data>(context);
	const { movespeed, range, moving } = data;

	return (
		<LabeledControls m={1}>
			<LabeledControls.Item label="Speed">
				<Knob
					inline
					size={1.2}
					step={0.5}
					stepPixelSize={10}
					value={movespeed}
					minValue={1}
					maxValue={10}
					onDrag={(_, value) => act('movespeed', { movespeed: value })}
				/>
			</LabeledControls.Item>
			<LabeledControls.Item label="Range">
				<Knob
					inline
					size={1.2}
					step={1}
					stepPixelSize={50}
					value={range}
					minValue={1}
					maxValue={7}
					onDrag={(_, value) => act('range', { range: value })}
				/>
			</LabeledControls.Item>
			<Stack.Item>
				<Divider vertical />
			</Stack.Item>
			<Stack.Item label="Simulation">
				<Button
					fluid
					selected={moving}
					content={
						<Box bold fontSize="1.4em" lineHeight={3}>
							{moving ? 'END' : 'BEGIN'}
						</Box>
					}
					onClick={() => act('toggle')}
				/>
			</Stack.Item>
		</LabeledControls>
	);
};

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { MainData } from './data';
import { MaintMode } from './MaintMode';
import { OperatorMode } from './OperatorMode';

export const Mecha = (props, context) => {
  const { data } = useBackend<MainData>(context);
  if (data.isoperator) {
    return (
      <Window theme={data.ui_theme} width={800} height={600}>
        <Window.Content>
          <OperatorMode />
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window theme={data.ui_theme} width={640} height={670}>
      <Window.Content>
        <MaintMode />
      </Window.Content>
    </Window>
  );
};

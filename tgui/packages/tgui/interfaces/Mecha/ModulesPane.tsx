import { useBackend } from '../../backend';
import { Icon, NumberInput, ProgressBar, Box, Button, Section, Stack, LabeledList, Divider, NoticeBox, Collapsible } from '../../components';
import { OperatorData, MechModule } from './data';
import { classes } from 'common/react';
import { toFixed } from 'common/math';
import { formatPower } from '../../format';
import { GasmixParser } from 'tgui/interfaces/common/GasmixParser';

const moduleSlotIcon = (param) => {
  switch (param) {
    case 'mecha_l_arm':
      return 'hand';
    case 'mecha_r_arm':
      return 'hand';
    case 'mecha_utility':
      return 'screwdriver-wrench';
    case 'mecha_power':
      return 'bolt';
    case 'mecha_armor':
      return 'shield-halved';
    default:
      return 'screwdriver-wrench';
  }
};

const moduleSlotLabel = (param) => {
  switch (param) {
    case 'mecha_l_arm':
      return 'Left arm module';
    case 'mecha_r_arm':
      return 'Right arm module';
    case 'mecha_utility':
      return 'Utility module';
    case 'mecha_power':
      return 'Power module';
    case 'mecha_armor':
      return 'Armor module';
    default:
      return 'Common module';
  }
};

export const ModulesPane = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { modules, selected_module_index, weapons_safety } = data;
  return (
    <Section
      title="Equipment"
      fill
      scrollable
      buttons={
        <Button
          icon={!weapons_safety ? 'triangle-exclamation' : 'helmet-safety'}
          color={!weapons_safety ? 'red' : 'default'}
          onClick={() => act('toggle_safety')}
          content={
            !weapons_safety
              ? 'Safety Protocols Disabled'
              : 'Safety Protocols Enabled'
          }
        />
      }>
      <Stack>
        <Stack.Item>
          {modules.map((module, i) =>
            !module.ref ? (
              <Button
                maxWidth={16}
                p="4px"
                pr="8px"
                fluid
                key={i}
                color="transparent">
                <Stack>
                  <Stack.Item width="32px" height="32px" textAlign="center">
                    <Icon
                      fontSize={1.5}
                      mx={0}
                      my="8px"
                      name={moduleSlotIcon(module.slot)}
                    />
                  </Stack.Item>
                  <Stack.Item
                    lineHeight="32px"
                    style={{
                      'text-transform': 'capitalize',
                      'overflow': 'hidden',
                      'text-overflow': 'ellipsis',
                    }}>
                    {`${moduleSlotLabel(module.slot)} Slot`}
                  </Stack.Item>
                </Stack>
              </Button>
            ) : (
              <Button
                maxWidth={16}
                p="4px"
                pr="8px"
                fluid
                key={i}
                selected={i === selected_module_index}
                onClick={() =>
                  act('select_module', {
                    index: i,
                  })
                }>
                <Stack>
                  <Stack.Item lineHeight="0">
                    <Box
                      className={classes(['mecha_equipment32x32', module.icon])}
                    />
                  </Stack.Item>
                  <Stack.Item
                    lineHeight="32px"
                    style={{
                      'text-transform': 'capitalize',
                      'overflow': 'hidden',
                      'text-overflow': 'ellipsis',
                    }}>
                    {module.name}
                  </Stack.Item>
                </Stack>
              </Button>
            )
          )}
        </Stack.Item>
        <Stack.Item grow pl={1}>
          {selected_module_index !== null && modules[selected_module_index] && (
            <ModuleDetails module={modules[selected_module_index]} />
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const ModuleDetails = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { slot, name, desc, icon, detachable, ref, snowflake } = props.module;
  return (
    <Stack vertical>
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <h2 style={{ 'text-transform': 'capitalize' }}>{name}</h2>
            <Box italic opacity={0.5}>
              {moduleSlotLabel(slot)}
            </Box>
          </Stack.Item>
          {!!detachable && (
            <Stack.Item>
              <Button
                icon="eject"
                tooltip="Detach"
                fontSize={1.5}
                onClick={() =>
                  act('equip_act', {
                    ref: ref,
                    gear_action: 'detach',
                  })
                }
              />
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
      <Stack.Item>{desc}</Stack.Item>
      <Divider />
      <Stack.Item>
        {!!snowflake &&
        snowflake.snowflake_id === MECHA_SNOWFLAKE_ID_AIR_TANK ? (
          <SnowflakeAirTank module={props.module} />
        ) : (
          <LabeledList>
            <ModuleDetailsBasic module={props.module} />
            {!!snowflake && <ModuleDetailsExtra module={props.module} />}
          </LabeledList>
        )}
      </Stack.Item>
    </Stack>
  );
};

const ModuleDetailsBasic = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { power_level, weapons_safety } = data;
  const {
    ref,
    slot,
    integrity,
    can_be_toggled,
    can_be_triggered,
    active,
    active_label,
    equip_cooldown,
    energy_per_use,
  } = props.module;
  return (
    <>
      {integrity < 1 && (
        <LabeledList.Item
          label="Integrity"
          buttons={
            <Button
              content={'Repair'}
              icon={'wrench'}
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: 'repair',
                })
              }
            />
          }>
          <ProgressBar
            ranges={{
              good: [0.75, Infinity],
              average: [0.25, 0.75],
              bad: [-Infinity, 0.25],
            }}
            value={integrity}
          />
        </LabeledList.Item>
      )}
      {!weapons_safety && ['mecha_l_arm', 'mecha_r_arm'].includes(slot) && (
        <LabeledList.Item label="Safety" color="red">
          <NoticeBox danger>SAFETY OFF</NoticeBox>
        </LabeledList.Item>
      )}
      {!!energy_per_use && (
        <LabeledList.Item label="Power Cost">
          {`${formatPower(energy_per_use)}, ${
            power_level ? toFixed(power_level / energy_per_use) : 0
          } uses left`}
        </LabeledList.Item>
      )}
      {!!equip_cooldown && (
        <LabeledList.Item label="Cooldown">{equip_cooldown}</LabeledList.Item>
      )}
      {!!can_be_toggled && (
        <LabeledList.Item label={active_label}>
          <Button
            icon="power-off"
            content={active ? 'Enabled' : 'Disabled'}
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'toggle',
              })
            }
            selected={active}
          />
        </LabeledList.Item>
      )}
      {!!can_be_triggered && (
        <LabeledList.Item label={active_label}>
          <Button
            icon="power-off"
            content="Activate"
            disabled={active}
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'toggle',
              })
            }
          />
        </LabeledList.Item>
      )}
    </>
  );
};

const MECHA_SNOWFLAKE_ID_SLEEPER = 'sleeper_snowflake';
const MECHA_SNOWFLAKE_ID_SYRINGE = 'syringe_snowflake';
const MECHA_SNOWFLAKE_ID_MODE = 'mode_snowflake';
const MECHA_SNOWFLAKE_ID_EXTINGUISHER = 'extinguisher_snowflake';
const MECHA_SNOWFLAKE_ID_EJECTOR = 'ejector_snowflake';
const MECHA_SNOWFLAKE_ID_OREBOX_MANAGER = 'orebox_manager_snowflake';
const MECHA_SNOWFLAKE_ID_RADIO = 'radio_snowflake';
const MECHA_SNOWFLAKE_ID_AIR_TANK = 'air_tank_snowflake';
const MECHA_SNOWFLAKE_ID_WEAPON_BALLISTIC = 'ballistic_weapon_snowflake';
const MECHA_SNOWFLAKE_ID_GENERATOR = 'generator_snowflake';

export const ModuleDetailsExtra = (props: { module: MechModule }, context) => {
  const module = props.module;
  switch (module.snowflake.snowflake_id) {
    case MECHA_SNOWFLAKE_ID_WEAPON_BALLISTIC:
      return <SnowflakeWeaponBallistic module={module} />;
    case MECHA_SNOWFLAKE_ID_EJECTOR:
      return <SnowflakeCargo module={module} />;
    case MECHA_SNOWFLAKE_ID_EXTINGUISHER:
      return <SnowflakeExtinguisher module={module} />;
    case MECHA_SNOWFLAKE_ID_OREBOX_MANAGER:
      return <SnowflakeOrebox module={module} />;
    case MECHA_SNOWFLAKE_ID_SLEEPER:
      return <SnowflakeSleeper module={module} />;
    case MECHA_SNOWFLAKE_ID_SYRINGE:
      return <SnowflakeSyringe module={module} />;
    case MECHA_SNOWFLAKE_ID_MODE:
      return <SnowflakeMode module={module} />;
    case MECHA_SNOWFLAKE_ID_RADIO:
      return <SnowflakeRadio module={module} />;
    case MECHA_SNOWFLAKE_ID_AIR_TANK:
      return <SnowflakeAirTank module={module} />;
    case MECHA_SNOWFLAKE_ID_GENERATOR:
      return <SnowflakeGeneraor module={module} />;
    default:
      return null;
  }
};

const SnowflakeWeaponBallistic = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { ref } = props.module;
  const {
    projectiles,
    max_magazine,
    projectiles_cache,
    projectiles_cache_max,
    disabledreload,
    ammo_type,
    mode,
  } = props.module.snowflake;
  return (
    <>
      {!!ammo_type && (
        <LabeledList.Item label="Ammo">{ammo_type}</LabeledList.Item>
      )}
      <LabeledList.Item
        label="Loaded"
        buttons={
          !disabledreload &&
          projectiles_cache > 0 && (
            <Button
              icon={'redo'}
              disabled={projectiles >= max_magazine}
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: 'reload',
                })
              }>
              Reload
            </Button>
          )
        }>
        <ProgressBar value={projectiles / max_magazine}>
          {`${projectiles} of ${max_magazine}`}
        </ProgressBar>
      </LabeledList.Item>
      {!!projectiles_cache_max && (
        <LabeledList.Item label="Stored">
          <ProgressBar value={projectiles_cache / projectiles_cache_max}>
            {`${projectiles_cache} of ${projectiles_cache_max}`}
          </ProgressBar>
        </LabeledList.Item>
      )}
      {!!mode && <SnowflakeMode module={props.module} />}
    </>
  );
};

const SnowflakeSleeper = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { ref } = props.module;
  const { patient } = props.module.snowflake;
  return !patient ? (
    <LabeledList.Item label="Patient">None</LabeledList.Item>
  ) : (
    <>
      <LabeledList.Item
        label="Patient"
        buttons={
          <Button
            icon="eject"
            tooltip="Eject"
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'eject',
              })
            }
          />
        }>
        {patient.patientname}
      </LabeledList.Item>
      <LabeledList.Item label={'Health'}>
        {patient.is_dead ? (
          <Box color="red">Patient dead</Box>
        ) : (
          <ProgressBar
            ranges={{
              good: [0.75, Infinity],
              average: [0.25, 0.75],
              bad: [-Infinity, 0.25],
            }}
            value={patient.patient_health}
          />
        )}
      </LabeledList.Item>
      <LabeledList.Item label={'Detailed Vitals'}>
        <Button
          content={'View'}
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'view_stats',
            })
          }
        />
      </LabeledList.Item>
    </>
  );
};

const SnowflakeSyringe = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { power_level, weapons_safety } = data;
  const { ref, energy_per_use, equip_cooldown } = props.module;
  const { mode, syringe, max_syringe, reagents, total_reagents } =
    props.module.snowflake;
  return (
    <>
      <LabeledList.Item label={'Syringes'}>
        <ProgressBar value={syringe / max_syringe}>
          {`${syringe} of ${max_syringe}`}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label={'Reagents'}>
        <ProgressBar value={reagents / total_reagents}>
          {`${reagents} of ${total_reagents} units`}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label={'Mode'}>
        <Button
          content={mode}
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'change_mode',
            })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item label={'Reagent control'}>
        <Button
          content={'View'}
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'show_reagents',
            })
          }
        />
      </LabeledList.Item>
    </>
  );
};

const SnowflakeMode = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { ref } = props.module;
  const { mode, mode_label } = props.module.snowflake;
  return (
    <LabeledList.Item label={mode_label}>
      <Button
        content={mode}
        onClick={() =>
          act('equip_act', {
            ref: ref,
            gear_action: 'change_mode',
          })
        }
      />
    </LabeledList.Item>
  );
};

const SnowflakeRadio = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { ref } = props.module;
  const { microphone, speaker, minFrequency, maxFrequency, frequency } =
    props.module.snowflake;
  return (
    <>
      <LabeledList.Item label="Microphone">
        <Button
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'toggle_microphone',
            })
          }
          selected={microphone}
          icon={microphone ? 'microphone' : 'microphone-slash'}>
          {(microphone ? 'En' : 'Dis') + 'abled'}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Speaker">
        <Button
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'toggle_speaker',
            })
          }
          selected={speaker}
          icon={speaker ? 'volume-up' : 'volume-mute'}>
          {(speaker ? 'En' : 'Dis') + 'abled'}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Frequency">
        <NumberInput
          animate
          unit="kHz"
          step={0.2}
          stepPixelSize={10}
          minValue={minFrequency / 10}
          maxValue={maxFrequency / 10}
          value={frequency / 10}
          format={(value) => toFixed(value, 1)}
          onDrag={(e, value) =>
            act('equip_act', {
              ref: ref,
              gear_action: 'set_frequency',
              new_frequency: value * 10,
            })
          }
        />
      </LabeledList.Item>
    </>
  );
};

const SnowflakeAirTank = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { cabin_dangerous_highpressure, cabin_sealed } = data;
  const { ref, integrity, active_label, active } = props.module;
  const {
    snowflake_id,
    air_source,
    airtank_pressure,
    airtank_temp,
    port_connected,
    cabin_pressure,
    cabin_temp,
    cabin_air,
    tank_air,
  } = props.module.snowflake;
  return (
    <Box>
      <LabeledList>
        {integrity < 1 && (
          <LabeledList.Item
            label="Integrity"
            buttons={
              <Button
                content={'Repair'}
                icon={'wrench'}
                onClick={() =>
                  act('equip_act', {
                    ref: ref,
                    gear_action: 'repair',
                  })
                }
              />
            }>
            <ProgressBar
              ranges={{
                good: [0.75, Infinity],
                average: [0.25, 0.75],
                bad: [-Infinity, 0.25],
              }}
              value={integrity}
            />
          </LabeledList.Item>
        )}
        <LabeledList.Item label={active_label}>
          <Button
            icon="power-off"
            content={
              active ? (!cabin_sealed ? 'Paused' : 'Enabled') : 'Disabled'
            }
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'toggle',
              })
            }
            selected={active}
          />
        </LabeledList.Item>
        <LabeledList.Item
          label="Tank Port"
          buttons={
            <Button
              icon="info"
              color="transparent"
              tooltip="Park above atmospherics connector port to connect inernal air tank with a gas network."
            />
          }>
          <Button
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'toggle_port',
              })
            }
            icon={port_connected ? 'plug-circle-check' : 'plug-circle-xmark'}
            selected={port_connected}>
            {port_connected ? 'Connected' : 'Disconnected'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
      <Section>
        {cabin_sealed ? (
          <Collapsible title="Cabin Air">
            <GasmixParser gasmix={cabin_air} />
          </Collapsible>
        ) : (
          <NoticeBox>
            <Icon name="wind" mr={1} />
            Cabin Open
          </NoticeBox>
        )}
        <Collapsible title="Tank Air">
          <GasmixParser gasmix={tank_air} />
        </Collapsible>
      </Section>
    </Box>
  );
};

const GetTempFormat = (temp) => {
  const KelvinZeroCelcius = 273.15;
  return (
    toFixed(temp - KelvinZeroCelcius, 1) + '°C (' + toFixed(temp, 1) + '°K)'
  );
};

const SnowflakeOrebox = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { ref } = props.module;
  const { cargo } = props.module.snowflake;
  return (
    <LabeledList.Item label="Action">
      <Button
        icon="arrows-down-to-line"
        onClick={() =>
          act('equip_act', {
            ref: ref,
            gear_action: 'dump',
          })
        }
        disabled={!cargo}>
        {cargo ? 'Dump contents' : 'Empty'}
      </Button>
    </LabeledList.Item>
  );
};

const SnowflakeCargo = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { ref } = props.module;
  const { cargo } = props.module.snowflake;
  return (
    <LabeledList.Item label="Cargo">
      {!cargo.length ? (
        <NoticeBox info>Compartment is empty</NoticeBox>
      ) : (
        cargo.map((item, i) => (
          <Button
            fluid
            py={0.2}
            key={i}
            tooltip="Eject"
            icon="eject"
            onClick={() =>
              act('equip_act', {
                ref: ref,
                cargoref: item.ref,
                gear_action: 'eject',
              })
            }
            style={{
              'text-transform': 'capitalize',
            }}>
            {item.name}
          </Button>
        ))
      )}
    </LabeledList.Item>
  );
};

const SnowflakeExtinguisher = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { ref } = props.module;
  const { reagents, total_reagents, reagents_required } =
    props.module.snowflake;
  return (
    <>
      <LabeledList.Item
        label="Water"
        buttons={
          <Button
            content={'Refill'}
            icon={'fill'}
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'refill',
              })
            }
          />
        }>
        <ProgressBar value={reagents} minValue={0} maxValue={total_reagents}>
          {reagents}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Activity">
        <Button
          content={'Extinguish'}
          color={'red'}
          disabled={reagents < reagents_required}
          icon={'fire-extinguisher'}
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'activate',
            })
          }
        />
      </LabeledList.Item>
    </>
  );
};

const SnowflakeGeneraor = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { sheet_material_amount } = data;
  const { ref, active, name } = props.module;
  const { fuel } = props.module.snowflake;
  return (
    <LabeledList.Item label="Fuel Amount">
      {fuel === null
        ? 'None'
        : toFixed(fuel * sheet_material_amount, 0.1) + ' cm³'}
    </LabeledList.Item>
  );
};

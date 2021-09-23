import { pureComponentHooks } from 'common/react';
import { Box, Icon, Flex, Section, Stack, Tooltip } from '../../components';

import { to_exponential_if_big } from './helpers';

/*
 * Shows a set of temperatures on a unified temperature scale.
 *
 * Axis labels draw attention to points of interest.
 *
 * This module is largely a proof of concept, partly reusing the guts of
 * ProgressBar css, and implementing a lot of use-specific logic.
 *
 * This is a good candidate for refactoring into something reusable, or
 * extending ProgressBar.
 */

const VerticalProgressBar = props => {
  const {
    borderRadius = "0.16em",
    color,
    falling=false,
    height,
    value,
    progressHeight,
    children
  } = props;
  const fill_dims = {}, anchor_dims = {}, container_dims = {};
  let y = height - progressHeight;
  if (falling) {
    fill_dims.top = '0px';
    fill_dims.bottom = `${y}px`;
    container_dims.top = '0px';
    anchor_dims.top = `${progressHeight}px`;
    anchor_dims.bottom = `${y}px`;
  } else {
    fill_dims.top = `${y}px`,
    fill_dims.bottom = '0px';
    container_dims.bottom = '0px';
    anchor_dims.top = `${y}px`;
    anchor_dims.bottom = `${progressHeight}px`;
  }
  return (<div className={`ProgressBar--color--${color}`} style={{
    display: 'absolute',
    position: 'relative',
    height: `${height}px`,
    width: '17px',
    padding: '0',
    "border-radius": borderRadius,
    ...container_dims
  }}>
    {
      !!value && (
        <>
          <div className="ProgressBar__fill ProgressBar__fill--animated" style={{
            position: 'absolute',
            left: '-0.5px',
            right: '-0.5px',
            "border-radius": borderRadius,
            ...fill_dims
          }} />
          {children && (
            <div style={{
              position: 'relative',
              height: '1px',
              ...anchor_dims,
              'background-color': 'magenta',
            }}>{children}</div>
          )}
        </>
      )
    }
  </div>);
};

export const HypertorusTemperatures = props => {
  const {
    powerLevel: power_level,
    baseMaxTemperature: base_max_temperature,
    internalFusionTemperature: internal_fusion_temperature,
    internalFusionTemperatureDelta: internal_fusion_temperature_delta,
    moderatorInternalTemperature: moderator_internal_temperature,
    moderatorInternalTemperatureDelta: moderator_internal_temperature_delta,
    internalOutputTemperature: internal_output_temperature,
    internalOutputTemperatureDelta: internal_output_temperature_delta,
    internalCoolantTemperature: internal_coolant_temperature,
    internalCoolantTemperatureDelta: internal_coolant_temperature_delta,
    selectedFuel: selected_fuel,
  } = props;

  let prev_power_level_temperature = 10 ** (1+power_level), next_power_level_temperature = 10 ** (2+power_level);

  if (power_level == 0) {
    prev_power_level_temperature = 0;
    next_power_level_temperature = 500;
  } else if (power_level == 1) {
    prev_power_level_temperature = 500;
  } else if (power_level == 6) {
    next_power_level_temperature = base_max_temperature * selected_fuel.temperature_multiplier;
  }

  const temperatures = [
    prev_power_level_temperature,
    next_power_level_temperature,
    ...[
      internal_fusion_temperature,
      moderator_internal_temperature,
      internal_output_temperature,
      internal_coolant_temperature,
    ].filter(d=>d),
  ].map(d=>parseFloat(d));

  const maxTemperature = Math.max(...temperatures);
  const minTemperature = Math.min(...temperatures);

  if (power_level == 6) {
    next_power_level_temperature = 0;
  }

  const height = 200;

  const yAxisLabelWidth = 60;
  const yAxisIconPadding = 2;
  const yAxisIconWidth = 14;
  const yAxisMargin = yAxisLabelWidth + yAxisIconWidth + yAxisIconPadding * 2;

  const value_to_y = (value, baseTemp = minTemperature, fromBottom=false) => {
    const ratio = (value - baseTemp) / (maxTemperature - minTemperature);
    const ret = height * (fromBottom ? (1 - ratio) : ratio);
    return ret;
  }

  const TemperatureLabel = (props, context) => {
    const {
      icon,
      force,
      tooltip,
      value,
      ...rest
    } = props;
    const y = value_to_y(value);
    const label = (
      <Box
        fluid
        align="right"
        color="label"
        position="absolute"
        top="0"
        left="0"
        width={`${yAxisMargin}px`}
        >
          {icon && (<Icon
            display="inline-block"
            mr={`${yAxisIconPadding}px`}
            name={icon}
          />)}
          {to_exponential_if_big(value) + " K"}
      </Box>
    );
    return (!!value || force) && (
      <Box fluid style={{
        position: 'absolute',
        top: `${height - y}px`,
        left: '0px',
        right: '20px',
      }}>
        <Box
          backgroundColor="label"
           style={{
            position: "absolute",
            left: `${yAxisMargin}px`,
            right: '0',
            top: '0.5em',
            height: '1px',
          }}
        />
        {tooltip ?
          (<Tooltip content={tooltip}>
            {label}
          </Tooltip>) :
          label
        }
      </Box>
    );
  };

  const TemperatureBar = (props, context) => {
    const {
      label,
      delta,
      value,
      children,
      ...rest
    } = props;
    const y = value_to_y(value);
    const delta_str = to_exponential_if_big(delta) + " K/s";
    return (
      <Flex.Item mx={1}>
        <Stack vertical align="center">
          <Stack.Item>
            <VerticalProgressBar height={height} progressHeight={y} value={value} {...rest}>{children}</VerticalProgressBar>
          </Stack.Item>
          <Stack.Item color="label">
            <Box align="center">{label}</Box>
            {value > 0 ? ([<Box align="center">
              {to_exponential_if_big(value) + " K"}
            </Box>,<Box align="center">{(delta > 0 ?
              `+${delta_str}` :
              delta < 0 ?
                `${delta_str}` :
                "-"
            )}</Box>]) : ([<Box align="center" color="red">
              Empty
            </Box>,<Box style={{
              "user-select": "none",
              "-ms-user-select": "none",
              unselectable: Byond.IS_LTE_IE8
            }}>
              &nbsp; {/* Placeholder. Geocities did nothing wrong :o) */}
            </Box>])}
          </Stack.Item>
        </Stack>
      </Flex.Item>
    );
  };

  return (
    <Section title="Temperatures">
      <Flex overflowY="hidden">
        <Flex.Item mx={1} width={`${yAxisMargin}px`}>
          {(power_level == 0 || value_to_y(Math.abs(prev_power_level_temperature - minTemperature), 0) > 20) && (<TemperatureLabel key="min_temp" value={minTemperature} force={true} />)}
          <TemperatureLabel key="prev_fusion_temp" icon="chevron-down" tooltip="Previous Fusion Level" value={prev_power_level_temperature} />
          <TemperatureLabel key="next_fusion_temp" icon="chevron-up" tooltip="Next Fusion Level" value={next_power_level_temperature} />
          {value_to_y(Math.abs(next_power_level_temperature - maxTemperature), 0) > 20 && (<TemperatureLabel key="max_temp" value={maxTemperature} />)}
        </Flex.Item>
        <TemperatureBar
          label="Fusion"
          value={internal_fusion_temperature}
          delta={internal_fusion_temperature_delta}
          color="orange" />
        <TemperatureBar
          label="Moderator"
          value={moderator_internal_temperature}
          delta={moderator_internal_temperature_delta}
          color="pink" />
        <TemperatureBar
          label="Coolant"
          value={internal_coolant_temperature}
          delta={internal_coolant_temperature_delta}
          color="aliceblue" />
        <TemperatureBar
          label="Output"
          value={internal_output_temperature}
          delta={internal_output_temperature_delta}
          color="green" />
      </Flex>
    </Section>
  );
};
HypertorusTemperatures.defaultHooks = pureComponentHooks;

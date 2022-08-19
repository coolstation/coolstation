/**
 * @file
 * @copyright 2022
 * @author Stonepillar (https://github.com/stonepillars)
 * @license ISC
 */

import { useBackend } from "../backend";
import { Window } from "../layouts";
import { NoticeBox, Stack, Section, Button } from "../components";

export interface TransitStopData {
  /** The registry key of the stop */
  id: string
  /** Whether the stop is disabled */
  disabled: number
  /** What to show on the button */
  label: string
  /** Is this the stop this terminal is at? */
  are_we_here?: number
}

export interface TransitTerminalData {
  /** Stops available to the vehicle */
  stops: TransitStopData[]
  /** Flag for if the vehicle is in transit */
  in_transit: number
  /** Flag for if the machine is in an illegal state. */
  panic: number
}

export const TransitTerminal = (_props, context) => {
  const { act, data } = useBackend<TransitTerminalData>(context);
  const { stops, in_transit, panic } = data;

  return (
    <Window
      resizable
      height={300}
      width={200}>
      <Window.Content>
        <Section>
          <Stack fill vertical>
            { panic ? (
              <NoticeBox danger>
                Something went wrong. Call 1-800-CODER for Support.
              </NoticeBox>)
              : ""}
            { stops.map(({ id, disabled, label }) => (
              <Button
                key={id}
                disabled={disabled || in_transit}
                onClick={() => act("move", { stopname: id })}>
                {label}
              </Button>
            ))}
          </Stack>
          { in_transit ? (
            <NoticeBox warning>
              The vehicle is moving. Please wait.
            </NoticeBox>
          )
            : ""}
        </Section>
      </Window.Content>
    </Window>
  );
};

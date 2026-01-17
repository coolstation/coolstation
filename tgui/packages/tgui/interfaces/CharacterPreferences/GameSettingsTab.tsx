import { useBackend } from '../../backend';
import { Box, Button, Image, LabeledList, Section } from '../../components';
import { CharacterPreferencesData, CharacterPreferencesTooltip } from './type';

export const GameSettingsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item
          label="Popup Font Size"
          buttons={
            <Button onClick={() => act("update-fontSize", { reset: 1 })}>
              Reset
            </Button>
          }
        >
          <Box mb="5px" color="label">
            Changes the font size used in popup windows. Only works when CHUI is
            disabled.
          </Box>
          <Button onClick={() => act("update-fontSize")}>
            {data.fontSize ? data.fontSize + "%" : "Default"}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Messages">
          <Box mb="5px" color="label">
            Toggles if certain messages are shown in the chat window by default.
            You can change these mid-round by using the Toggle OOC/LOOC commands
            under the Commands tab in the top right.
          </Box>
          {data.isMentor ? (
            <Box mb="5px">
              <Button.Checkbox
                checked={data.seeMentorPms}
                onClick={() => act("update-seeMentorPms")}
              >
                Display Mentorhelp
              </Button.Checkbox>
            </Box>
          ) : null}
          <Box mb="5px">
            <Button.Checkbox
              checked={data.listenOoc}
              onClick={() => act("update-listenOoc")}
            >
              Display OOC chat
            </Button.Checkbox>
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.listenLooc}
              onClick={() => act("update-listenLooc")}
            >
              Display LOOC chat
            </Button.Checkbox>
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={!data.flyingChatHidden}
              onClick={() => act("update-flyingChatHidden")}
            >
              See chat above people&apos;s heads
            </Button.Checkbox>
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.autoCapitalization}
              onClick={() => act("update-autoCapitalization")}
            >
              Auto-capitalize your messages
            </Button.Checkbox>
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.localDeadchat}
              onClick={() => act("update-localDeadchat")}
            >
              Local ghost hearing
            </Button.Checkbox>
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="HUD Theme">
          <Box mb="5px">
            <Button onClick={() => act("update-hudTheme")}>
              Change
            </Button>
          </Box>
          <Box>
            <Image
              pixelated
              src={`hud_preview_${data.hudTheme}.png`}
              width="32px"
              height="32px"
            />
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Targeting Cursor">
          <Box mb="5px">
            <Button onClick={() => act("update-targetingCursor")}>
              Change
            </Button>
          </Box>
          <Box>
            <Image
              pixelated
              src={`tcursor_${data.targetingCursor}.png`}
              width="32px"
              height="32px"
            />
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Tooltips">
          <Box mb="5px" color="label">
            Tooltips can appear when hovering over items. These tooltips can
            provide bits of information about the item, such as attack strength,
            special moves, etc.
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={
                data.tooltipOption === CharacterPreferencesTooltip.Always
              }
              onClick={() =>
                act("update-tooltipOption", {
                  value: CharacterPreferencesTooltip.Always,
                })}
            >
              Show Always
            </Button.Checkbox>
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.tooltipOption === CharacterPreferencesTooltip.Alt}
              onClick={() =>
                act("update-tooltipOption", {
                  value: CharacterPreferencesTooltip.Alt,
                })}
            >
              Show When ALT is held
            </Button.Checkbox>
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.tooltipOption === CharacterPreferencesTooltip.Never}
              onClick={() =>
                act("update-tooltipOption", {
                  value: CharacterPreferencesTooltip.Never,
                })}
            >
              Never Show
            </Button.Checkbox>
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="tgui">
          <Box mb="5px" color="label">
            tgui is the UI framework we use for some game windows, and it comes
            with options!
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.tguiFancy}
              onClick={() => act("update-tguiFancy")}
            >
              Fast & Fancy Windows
            </Button.Checkbox>
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.tguiLock}
              onClick={() => act("update-tguiLock")}
            >
              Lock initial placement of windows
            </Button.Checkbox>
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Popups">
          <Box mb="5px" color="label">
            These options toggle the popups that appear when logging in and at
            the end of a round.
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.viewChangelog}
              onClick={() => act("update-viewChangelog")}
            >
              Auto-open changelog
            </Button.Checkbox>
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.viewScore}
              onClick={() => act("update-viewScore")}
            >
              Auto-open end-of-round score
            </Button.Checkbox>
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.viewTickets}
              onClick={() => act("update-viewTickets")}
            >
              Auto-open end-of-round ticket summary
            </Button.Checkbox>
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Controls">
          <Box mb="5px" color="label">
            Various options for how you control your character and the game.
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.useClickBuffer}
              onClick={() => act("update-useClickBuffer")}
            >
              Queue Combat Clicks
            </Button.Checkbox>
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.useWasd}
              onClick={() => act("update-useWasd")}
            >
              Use WASD Mode
            </Button.Checkbox>
          </Box>
          <Box mb="5px">
            <Button.Checkbox
              checked={data.useAzerty}
              onClick={() => act("update-useAzerty")}
            >
              Use AZERTY Keyboard Layout
            </Button.Checkbox>
          </Box>
          <Box color="label">
            Familiar with /tg/station controls? You can enable/disable them
            under the Game/Interface menu in the top left.
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Preferred Map">
          <Button onClick={() => act("update-preferredMap")}>
            {data.preferredMap ? data.preferredMap : <Box italic>None</Box>}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Lobby Music">
          <Box mb="5px">
            <Button.Checkbox
              checked={data.skipLobbyMusic}
              onClick={() => act("update-lobbymusic")}
            >
              Skip Lobby Music
            </Button.Checkbox>
          </Box>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

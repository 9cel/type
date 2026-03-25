# clickity

Plays mechanical keyboard click sounds when you type on macOS. Runs as a background daemon with a CLI for control.

## Install

```
brew tap 9cel/tap
brew install clickity
brew services start clickity
# Grant Accessibility permission as described below

# If it doesn't work immediately after granting permission, restart the service:
brew services restart clickity
```

### Accessibility Permission

You'll need to grant Accessibility permission to the `ty` binary. On first launch, open System Settings > Privacy & Security > Accessibility, hit +, press Cmd+Shift+G, and paste the path shown in `brew info clickity`.

### Dependencies


You may need to install libyaml and libsoundio:

```
brew install libyaml libsoundio
```

## Usage

```
clickity status                      Show current state
clickity on                          Enable sounds
clickity off                         Disable sounds
clickity switch cherrymx-blue-abs    Switch sound profile
clickity vol 80                      Set volume (0-100)
clickity list                        List available profiles
```

## Profiles

cherrymx-black-abs, cherrymx-black-pbt, cherrymx-blue-abs, cherrymx-blue-pbt, cherrymx-brown-abs, cherrymx-brown-pbt, cherrymx-red-abs, topre-purple-hybrid-pbt

Sound samples from the Mechvibes project.

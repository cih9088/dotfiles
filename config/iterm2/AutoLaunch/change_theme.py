#!/usr/bin/env python3

import asyncio
import iterm2

async def changeProfile(connection,parts,app):

    # Update the list of all profiles and iterate over them.
    profiles = await iterm2.PartialProfile.async_query(connection)
    for partial in profiles:
        #  Fetch the full profile and then set the color preset in it.
        if ("dark" in parts and partial.name == "dark") or \
                ("light" in parts and partial.name == "light"):
            profile = await partial.async_get_full_profile()
            await app.current_terminal_window.current_tab.current_session.async_set_profile(profile)
            return


async def changeTheme(connection,parts):
    theme_dark = "seoul256"
    theme_light = "seoul256-light-modified"

    if "dark" in parts:
        preset = await iterm2.ColorPreset.async_get(connection, theme_dark)
    else:
        preset = await iterm2.ColorPreset.async_get(connection, theme_light)

    # Update the list of all profiles and iterate over them.
    profiles = await iterm2.PartialProfile.async_query(connection)
    for partial in profiles:
        # Fetch the full profile and then set the color preset in it.
        profile = await partial.async_get_full_profile()
        await profile.async_set_color_preset(preset)
        return


async def main(connection):

    app = await iterm2.async_get_app(connection)
    initial_theme = await app.async_get_theme()
    #  await changeTheme(connection,initial_theme)
    await changeProfile(connection,initial_theme,app)

    async with iterm2.VariableMonitor(connection, iterm2.VariableScopes.APP, "effectiveTheme", None) as mon:
        while True:
            # Block until theme changes
            theme = await mon.async_get()
            # Themes have space-delimited attributes, one of which will be light or dark.
            parts = theme.split(" ")

            #  await changeTheme(connection,parts)
            await changeProfile(connection,parts,app)


iterm2.run_forever(main)


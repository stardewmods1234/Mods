function hideToshi(location, tilepos, layer)

  print('toshi hiding start')
  if Game1.player.mailReceived.Contains('toshiNeedsVanishing') then
    Game1.player.mailReceived.Remove('toshiNeedsVanishing')
    Game1.getCharacterFromName('Toshinori').isInvisible.Value=true
    Game1.getCharacterFromName('Toshinori').daysUntilNotInvisible=2147483647
    print('abracadabra')

  else print('no flag')
  end

end
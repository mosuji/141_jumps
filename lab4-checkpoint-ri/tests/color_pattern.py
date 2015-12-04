#!/usr/bin/python2.7

y = ['000000', '00005f', '000080', '000087', '0000af', '0000d7', '0000ff', '005f00', '005f5f', '005f87', '005faf', '005fd7', '005fff', '008000', '008080', '008700', '00875f', '008787', '0087af', '0087d7', '0087ff', '00af00', '00af5f', '00af87', '00afaf', '00afd7', '00afff', '00d700', '00d75f', '00d787', '00d7af', '00d7d7', '00d7ff', '00ff00', '00ff5f', '00ff87', '00ffaf', '00ffd7', '00ffff', '080808', '121212', '1c1c1c', '262626', '286898', '303030', '3a3a3a', '444444', '4e4e4e', '585858', '5f0000', '5f005f', '5f0087', '5f00af', '5f00d7', '5f00ff', '5f5f00', '5f5f5f', '5f5f87', '5f5faf', '5f5fd7', '5f5fff', '5f8700', '5f875f', '5f8787', '5f87af', '5f87d7', '5f87ff', '5faf00', '5faf5f', '5faf87', '5fafaf', '5fafd7', '5fafff', '5fd700', '5fd75f', '5fd787', '5fd7af', '5fd7d7', '5fd7ff', '5fff00', '5fff5f', '5fff87', '5fffaf', '5fffd7', '5fffff', '626262', '6c6c6c', '767676', '800000', '800080', '808000', '808080', '870000', '87005f', '870087', '8700af', '8700d7', '8700ff', '875f00', '875f5f', '875f87', '875faf', '875fd7', '875fff', '878700', '87875f', '878787', '8787af', '8787d7', '8787ff', '87af00', '87af5f', '87af87', '87afaf', '87afd7', '87afff', '87d700', '87d75f', '87d787', '87d7af', '87d7d7', '87d7ff', '87ff00', '87ff5f', '87ff87', '87ffaf', '87ffd7', '87ffff', '8a8a8a', '949494', '9e9e9e', 'a8a8a8', 'af0000', 'af005f', 'af0087', 'af00af', 'af00d7', 'af00ff', 'af5f00', 'af5f5f', 'af5f87', 'af5faf', 'af5fd7', 'af5fff', 'af8700', 'af875f', 'af8787', 'af87af', 'af87d7', 'af87ff', 'afaf00', 'afaf5f', 'afaf87', 'afafaf', 'afafd7', 'afafff', 'afd700', 'afd75f', 'afd787', 'afd7af', 'afd7d7', 'afd7ff', 'afff00', 'afff5f', 'afff87', 'afffaf', 'afffd7', 'afffff', 'b2b2b2', 'bcbcbc', 'c0c0c0', 'c6c6c6', 'd0d0d0', 'd70000', 'd7005f', 'd70087', 'd700af', 'd700d7', 'd700ff', 'd75f00', 'd75f5f', 'd75f87', 'd75faf', 'd75fd7', 'd75fff', 'd78700', 'd7875f', 'd78787', 'd787af', 'd787d7', 'd787ff', 'dadada', 'dfaf00', 'dfaf5f', 'dfaf87', 'dfafaf', 'dfafdf', 'dfafff', 'dfdf00', 'dfdf5f', 'dfdf87', 'dfdfaf', 'dfdfdf', 'dfdfff', 'dfff00', 'dfff5f', 'dfff87', 'dfffaf', 'dfffdf', 'dfffff', 'e4e4e4', 'eeeeee', 'ff0000', 'ff005f', 'ff0087', 'ff00af', 'ff00df', 'ff00ff', 'ff5f00', 'ff5f5f', 'ff5f87', 'ff5faf', 'ff5fdf', 'ff5fff', 'ff8700', 'ff875f', 'ff8787', 'ff87af', 'ff87df', 'ff87ff', 'ffaf00', 'ffaf5f', 'ffaf87', 'ffafaf', 'ffafdf', 'ffafff', 'ffdf00', 'ffdf5f', 'ffdf87', 'ffdfaf', 'ffdfdf', 'ffdfff', 'ffff00', 'ffff5f', 'ffff87', 'ffffaf', 'ffffdf', 'ffffff']

if __name__ == "__main__":
	for ii, raw_color in enumerate(y):
		rgb = int(raw_color, 16)
		print raw_color
		"""
		r = (rgb & 0xff0000) >> 16
		gb = (rgb & 0x00ffff)
		print "addi $1, $0, %d"%r
		print "addi $2, $0, %d"%gb
		print "sll  $1, $1, 16"
		print "or   $1, $1, $2"
		print "lw   $1, %s($0)"%hex(ii)
	"""

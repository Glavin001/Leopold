#!/usr/bin/env python
import os, sys, pygtk
root = ''.join([e+'/' for e in os.path.realpath(__file__).split('/')[0:-1]])
pygtk.require('2.0')
import gtk
global result
from subprocess import call
if gtk.pygtk_version < (2,3,90):
   print "PyGtk 2.3.90 or later required for this example"
   raise SystemExit

class pluginInfoDisplay():
	def main(self):
		gtk.main()
	def close(self,widget):
		gtk.main_quit()
	def __init__(self,message):
		self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
		self.window.set_title("Palaver Plugin Installer")
		self.window.set_size_request(600,100)
		self.lblMessage = gtk.Label(message)
		self.box = gtk.HBox()
		self.box.pack_start(self.lblMessage)
		self.window.add(self.box)
		self.window.show_all()
		self.window.connect("destroy",self.close)

dialog = gtk.FileChooserDialog("Open an Speech Plugin",
                               None,
                               gtk.FILE_CHOOSER_ACTION_OPEN,
                               (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL,
                                gtk.STOCK_OPEN, gtk.RESPONSE_OK))
dialog.set_default_response(gtk.RESPONSE_OK)

filter = gtk.FileFilter()
filter.set_name("Speech Plugin")
filter.add_pattern("*.sp")
dialog.add_filter(filter)

filter = gtk.FileFilter()
filter.set_name("All files")
filter.add_pattern("*")
dialog.add_filter(filter)

response = dialog.run()
if response == gtk.RESPONSE_OK:
	filename = dialog.get_filename()
elif response == gtk.RESPONSE_CANCEL:
	print 'Installation Cancelled'
	sys.exit(0)
dialog.destroy()

call(["./plugins_manager", "-i", filename, "-f"])

data = open("InstallResult")
message = data.read()
data.close()
result = pluginInfoDisplay(message)
result.main()

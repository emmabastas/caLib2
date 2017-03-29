#!/usr/bin/env python

import subprocess
import os
import shutil
import fnmatch
import sys


def add_module_paths():
	paths = []

	for dsourcePath in dsourcePaths:
		for root, directory, files in os.walk(dsourcePath):
			for item in fnmatch.filter(files, '*'):
				if item[len(item)-2:] == '.d':
					paths.append(root + '/' + item)
	return paths


rootDir = os.path.dirname(os.path.realpath(__file__)).replace('\\', '/') + "/../"

dsourcePaths = [rootDir + 'src/']

importPaths = [
	rootDir + '/',
	'../../../AppData/Roaming/dub/packages/derelict-sdl2-2.0.2/derelict-sdl2/source/',
	'../../../AppData\Roaming\dub\packages\derelict-fi-FreeImage-3.15.x\derelict-fi\source',
	'../../../AppData/Roaming/dub/packages/derelict-util-2.0.6/derelict-util/source/',
	'../../../AppData/Roaming/dub/packages/imaged-1.0.2/imaged/',
	'../../../AppData/Roaming/dub/packages/undead-1.0.6/undead/src/',
	'../../../.dub/packages/derelict-sdl2-2.0.2/source/',
	'../../../.dub/packages/derelict-util-2.0.6/source/',
	'../../../.dub/packages/imaged-1.0.2/',
	'../../../.dub/packages/undead-1.0.6/src/',
	'../../../.dub/packages/derelict-fi-FreeImage-3.15.x/derelict-fi/source/',
	'../../../.dub/packages/derelict-util-2.0.6/derelict-util/source/',
	'../../../.dub/packages/derelict-sdl2-2.0.2/derelict-sdl2/source/',
	'/usr/include/dmd/phobos',
	'/usr/include/dmd/druntime/import',
] + dsourcePaths

includedFiles = [
	'ddoc/tree.ddoc',
	'ddoc/macros.ddoc',
] + add_module_paths()


def main():
	update_tree()

	# remove "docs" should it exist
	remove_file_or_dir(rootDir + 'docs')

	# build docs with dmd
	commandHead = 'dmd -o- -D -Dd{0}docs'.format(rootDir)
	command = commandHead + ' -I' + ' -I'.join(importPaths) + ' ' + ' '.join(includedFiles)
	subprocess.Popen(command.split(' '), cwd=rootDir)

	# copy the directory "ddoc" to "docs/ddoc"
	shutil.copytree(rootDir + 'ddoc', rootDir + 'docs/ddoc')


def update_tree():

	buff = 'TREE =  \n'
	buff = buff + '<ul>\n'

	for dsourcePath in dsourcePaths:
		buff = buff + update_tree_(dsourcePath)

	buff = buff + '</ul>'

	remove_file_or_dir(rootDir + 'ddoc/tree.ddoc')
	with open(rootDir + 'ddoc/tree.ddoc', 'wb') as temp_file:
		temp_file.write(buff + '\n')


def update_tree_(path, i=1):
	buff = ''

	for f in os.listdir(path):
		if os.path.isfile(path + f):
			buff = buff + '    '*i
			buff = buff + '<li><a href="' + filepath_to_url(path + f) +'">'
			buff = buff + filepath_to_dpath(path + f, path)
			buff = buff + '</a></li>\n'

	for d in os.listdir(path):
		if os.path.isdir(path + d):
			buff = buff + '    '*i + '<li>' + filepath_to_dpath(path + d, path) + '<ul>\n' #'\n'
			#buff = buff + '    '*(i+1) + '<ul>\n'
			buff = buff + update_tree_(path + d + '/', i+2)
			buff = buff + '    '*(i+1) + '</ul>\n'
			buff = buff + '    '*i + '</li>' + '\n'

	return buff


def filepath_to_dpath(filepath, directory):

	filepath = os.path.join(directory, filepath)
	filepath = filepath[len(directory):]

	if filepath[len(filepath)-2:] == '.d':
		filepath = filepath[:-2]

	filepath = filepath.replace('/', '.')

	return filepath


def filepath_to_url(filepath):
	filepath = filepath.split('/')
	filepath = filepath[len(filepath)-1]
	filepath = filepath[0:-(len(filepath)-filepath.index('.'))] + '.html'
	return filepath

def remove_file_or_dir(path):
	try:
		os.remove(path)
	except OSError:
		pass
	try:
		shutil.rmtree(path)
	except OSError:
		pass


if __name__ == "__main__":
	print "building docs..."
	main()
	print "done building docs"

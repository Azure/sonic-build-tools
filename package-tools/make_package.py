#!/usr/bin/python

import subprocess
import os
import sys
import shutil
import json

def __run(args,inp):
    if type(args)==dir:
        args = [ d for d in args.itervalues()]
    __process = subprocess.Popen(args,  stdout=subprocess.PIPE,
                    stdin=subprocess.PIPE)
    
    stdout = __process.communicate(input=''.join(inp))[0]

    return stdout

def _load_cfg():
    d = {}
    try:
        with open('package.cfg') as f:
            d = json.load(f)
    except:
        pass
    return d

def write_to_file(f,lst):
    f.write(''.join(lst)+'\n')

if __name__== '__main__':
    d = _load_cfg()

#    if os.path.exists('debian'):
#        print('Please remove existing debian folder before continuing.')
#        sys.exit(-1)

    try:
        shutil.rmtree('_debian')
    except Exception as e:
        pass
    
    try:
        shutil.rmtree('debian')
    except Exception as e:
        pass
    
    os.mkdir('debian')

    with open('debian/control','w') as f:
        pkgs = d['packages']
        for pkg in pkgs:        
            name = pkg['name']
            write_to_file(f,['Source: ',pkg['name']])
            write_to_file(f,['Section: net'])
            write_to_file(f,['Priority: optional'])
            write_to_file(f,['Maintainer: ',d['maintainer']])
            _basic_deps = 'debhelper (>= 9), autotools-dev'
            if 'build_depends' in d and len(d['build_depends']) > 0:
                _basic_deps+=','
                _basic_deps+=','.join(d['build_depends'])
            write_to_file(f,['Build-Depends: '+_basic_deps ] )
            write_to_file(f,['Standards-Version: 3.9.3'])
            break

        for pkg in pkgs:        
                write_to_file(f,['\nPackage: ',pkg['name']])
                write_to_file(f,['Architecture: ','any'])
                write_to_file(f,
                    ['Depends: ','${shlibs:Depends}, ${misc:Depends},',
                    ','.join(pkg['dependencies'])])
                write_to_file(f,['Description: ',d['description'],'\n'])

        shutil.copyfile(os.path.join(os.path.dirname(sys.argv[0]),'rules.template'),'debian/rules')
        shutil.copyfile(os.path.join(os.path.dirname(sys.argv[0]),'compat.template'),'debian/compat')

    with open('debian/rules','aw') as f:
        f.write('override_dh_gencontrol:\n')
        for pkg in pkgs:
            f.write('\tdh_gencontrol -p'+pkg['name']+'\n')
        f.write("""       
override_dh_auto_install:
\tdh_auto_install            
""")
    __run(['chmod','a+x','debian/rules'],[])

    with open('debian/changelog','aw') as f:
        f.write(name+' ('+d['version']+') main; urgency=medium\n')
        f.write('\n')
        f.write('\t * Initial release\n')
        f.write('\n')
        f.write(' -- Dell Team <support@dell.com> Mon, 29 Feb 2016 11:12:18 -0800\n')
    for pkg in pkgs:
        name = pkg['name']
        with open('debian/'+name+'.install','w') as f:
            for _elem in pkg['files']:
                f.write(_elem+'\n')


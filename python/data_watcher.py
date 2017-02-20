# Watches for changes in the data directory in order to automatically detect the data output by BCI and ERP

import os, sys
import time
import glob

class DirectoryListener(object):
    def __init__(self, dirname, ext='*'):
        self.dirname = dirname
        self.ext = ext
        paths = glob.glob(dirname + ext)
        self.metadata = {path: os.path.getmtime(path) for path in paths}

    def check_for_changed(self, verbose=True):
        paths = glob.glob(self.dirname + self.ext)
        new_metadata = {path: os.path.getmtime(path) for path in paths}

        if len(new_metadata) != len(self.metadata):         # file was added or deleted
            sys.stdout.write('Something added/deleted\n')
            sys.stdout.flush()
            if len(new_metadata) != len(self.metadata) + 1: # change other than a single file was added
                raise RuntimeError('More than one file has changed, cannot infer the target')
            newfile = [key for key in new_metadata if key not in self.metadata][0]
            if verbose: print('New file detected:', newfile)
            self.metadata = new_metadata
            return newfile
        diffs = [path for path in paths if new_metadata[path] != self.metadata[path]]
        if len(diffs) > 1:
            raise RuntimeError('More than one file has changed, cannot infer the target')
        elif len(diffs) == 1:
            if verbose: print('Changed file detected:', diffs[0])
            self.metadata = new_metadata
            return diffs[0]
        return None

    def serve_indefinitely(self, sleeptime=0.5):
        while True:
            sys.stdout.write(str(len(self.metadata))+'.')
            sys.stdout.flush()
            result = self.check_for_changed()
            if result:
                sys.stdout.write(result +'\n')
                sys.stdout.flush()
            time.sleep(sleeptime)

if __name__ == '__main__':
    bci_path = '/home/mike/as/obci/OpenBCI_Processing/OpenBCI_GUI/SavedData/'
    resp_path = '/home/mike/Downloads/'
    output_path = '/home/mike/as/obci/erp_data/'

    if not os.path.exists(bci_path):
        raise FileNotFoundError('Path for BCI output is not valid: {}'.format(bci_path))
    if not os.path.exists(resp_path):
        raise FileNotFoundError('Path for ERP output is not valid: {}'.format(resp_path))

    if not os.path.exists(output_path):
        try:
            os.mkdir(output_path)
            print('Could not find output path, so created it: {}'.format(output_path))
        except IOError as err:
            print('Tried to create path, but failed: {}'.format(output_path))
            raise err

    listener = DirectoryListener(bci_path)
    listener.serve_indefinitely()


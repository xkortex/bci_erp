import numpy as np, pandas as pd
import glob
import os
from datetime import datetime
import pytz


def process_resp(path_resp):
    resp = pd.read_csv(path_resp)
    resp['unixtime'] = pd.to_numeric(resp['unixtime'])
    resp.sort_values('unixtime', inplace=True)

    return resp

def process_bci(path_bci):
    bci = pd.read_csv(path_bci, sep=', ', skiprows=6, header=None)
    chan_columns = [str(i) for i in range(1, 9)]
    bci.columns = ['ticks'] + chan_columns + ['a', 'b', 'c', 'unixtime']
    bci['unixtime'] = pd.to_numeric(bci['unixtime'])
    return bci

def combine_resp_bci(resp, bci):
    t0 = bci.loc[0, 'unixtime']
    resp['latency'] = resp['unixtime'] - t0
    bci['latency'] = bci['unixtime'] - t0
    tonef = resp['tone'].replace({'F4': 1, 'G5': 2, 'F4': 0})
    resp['tonef'] = pd.Series(tonef, dtype='float64')
    bci = bci[pd.notnull(bci['unixtime'])] # eliminate nulls/nans
    bci['unixtime'] = pd.Series(bci['unixtime'], dtype='int64')
    merged = pd.merge_asof(bci, resp, on='unixtime', allow_exact_matches=False)
    merged['dtone'] = merged['tonef'].diff().fillna(0)
    merged['oddball'] = merged['dtone'] == 2
    merged.drop(['a', 'b', 'c', 'dtone'], axis=1, inplace=True)
    merged = pd.merge_asof(bci, resp, on='unixtime', allow_exact_matches=False)
    return (resp, bci, merged)

def export_resp_to_minimal_csv(resp, path):
    export_file = resp[['type', 'latency']]
    export_file.to_csv(path, index=0)


if __name__ == '__main__':
    run_dir_format = 'run*/'
    bci_format = 'OpenBCI-RAW*.txt'
    resp_format = 'oddball_run*.csv'
    trials_path = '/home/mike/as/obci/OpenBCI_Processing/OpenBCI_GUI/SavedData/'


    if not os.path.exists(trials_path):
        raise FileNotFoundError('Path for BCI output is not valid: {}'.format(trials_path))

    trial_dirs = glob.glob(trials_path + run_dir_format)
    print('Found {} trials'.format(len(trial_dirs)))
    for path in trial_dirs:
        print(os.path.basename(os.path.normpath(path)))
        bci = glob.glob(path + bci_format)[0]
        resp = glob.glob(path + resp_format)[0]
        base_timestamp = os.path.basename(resp)[12:-4]
        bci = process_bci(bci)
        resp = process_resp(resp)
        print(' Base timestamp: {}'.format(base_timestamp))
        print('  Events:     {}'.format(len(resp)))
        print('  Datapoints: {}'.format(len(bci)))
        resp, bci, merged = combine_resp_bci(resp, bci)
        export_pathname = path + '/' + 'events_' + base_timestamp + '.txt'
        minimal_resp = export_resp_to_minimal_csv(resp, export_pathname)


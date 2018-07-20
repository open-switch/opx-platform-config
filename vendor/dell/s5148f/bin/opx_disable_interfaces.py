import cps
import sys
import cps_object
import cps_utils

_intf_key   = 'dell-base-if-cmn/if/interfaces/interface'
_name_attr  = 'if/interfaces/interface/name'
_admin_attr = 'if/interfaces/interface/enabled'
_type_attr  = 'if/interfaces/interface/type'

class Cps_Exception(Exception):
    ''' Exception Class '''
    pass

def cps_attr_data_get(obj, attr):
    ''' Method to get Attributes Data '''
    d = obj['data']
    if attr not in d:
        return None
    return cps_utils.cps_attr_types_map.from_data(attr, d[attr])

def cps_get(obj, q='observed', attrs={}):
    ''' CPS Get '''
    resp = []
    if cps.get([cps_object.CPSObject(obj, qual=q, data=attrs).get()], resp):
        return resp
    raise Cps_Exception

def cps_set(obj, q='target', attrs={}):
    ''' CPS Set '''
    if cps.transaction([{'operation': 'set', 'change': cps_object.CPSObject(obj, qual=q, data=attrs).get()}]):
        return True
    raise Cps_Exception

def set_intf(name, admin_state):
    ''' Method to Set Interface '''
    cps_set(_intf_key, 'target', {_name_attr:name, _admin_attr:admin_state})

def get_all_intf():
    ''' Method to Get All Interfaces '''
    if_name_list = []
    resp = cps_get(_intf_key, 'target', {_type_attr:'ianaift:ethernetCsmacd'})
    for r in resp:
        s = cps_attr_data_get(r, _name_attr)
        if s is not None:
            if_name_list.append(str(s))
    return if_name_list

if __name__ == '__main__':
    
    if_name_list = []
    try:
        if_name_list = get_all_intf()
    except:
        print("Failed to get interface list")
        sys.exit(1)
    
    admin_state = 0
    for e in if_name_list:
        try:
            set_intf(e, admin_state)
        except:
            print("Failed to set admin down for interface: " + str(e))
            pass

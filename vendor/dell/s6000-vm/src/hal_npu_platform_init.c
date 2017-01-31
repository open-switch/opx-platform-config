/*
 * Copyright (c) 2016 Dell Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License. You may obtain
 * a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * THIS CODE IS PROVIDED ON AN  *AS IS* BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT
 *  LIMITATION ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS
 * FOR A PARTICULAR PURPOSE, MERCHANTABLITY OR NON-INFRINGEMENT.
 *
 * See the Apache Version 2.0 License for specific language governing
 * permissions and limitations under the License.
 */

/*!
 * \file   hal_npu_platform_init.c
 * \brief  hal platform init functions for VM platform
 * \date   03-2015
 */


#include "nas_ndi_plat_stat.h"
#include "std_error_codes.h"
#include <stdint.h>


t_std_error ndi_plat_get_ids_len(nas_stat_type_t type, unsigned int * len){
    // This value is set to 1 as apis querying this creates array based on the length passed
    *len = 1;
    return STD_ERR_OK;
}

t_std_error ndi_plat_port_stat_list_get(uint64_t * list, unsigned int *len){
    return STD_ERR_OK;
}

t_std_error ndi_plat_vlan_stat_list_get(uint64_t  *list, unsigned int *len){
    return STD_ERR_OK;
}

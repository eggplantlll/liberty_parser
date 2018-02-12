#include "si2dr_liberty.h"
#include <stdio.h>
#include <stdlib.h>
#include "attr_enum.h"
#include "group_enum.h"


// read_lib
// {{{
si2drGroupIdT read_lib (char *filename) {
  si2drErrorT err; si2drPIInit(&err);

  si2drGroupIdT  group;
  si2drGroupsIdT groups;

  si2drReadLibertyFile(filename, &err);

  //group = si2drPIFindGroupByName("sample","library",&err);
  // The groups can contains multiple groups if multiple .lib were read or if a
  // .lib file contains multiple library() session.
  // In here,because only one file can be read and a single contain only one library()
  // the `groups' contain single group.
  groups = si2drPIGetGroups(&err);
  // Use IterNextGroup to locate the ID of library group.
  group  = si2drIterNextGroup(groups, &err);

  return group;
}
// }}}
// get_group_name
// {{{
si2drStringT get_group_name (si2drGroupIdT group) {
  si2drErrorT err;

  si2drNamesIdT names;
  si2drStringT str;

  names = si2drGroupGetNames(group, &err);
  str = si2drIterNextName(names,&err);
  if (str == NULL) {
    return "NA";
  } else {
    return str;
  }

  //printf("%s\n", str);
}
// }}}
// get_group_type
// {{{
si2drStringT get_group_type (si2drGroupIdT group) {
  si2drErrorT err;

  si2drStringT str;

  str = si2drGroupGetGroupType(group, &err);
  return str;

  //printf("%s\n", str);
}
// }}}
// locate_cell
// {{{
si2drGroupIdT locate_cell (si2drGroupIdT group, char *name) {
  si2drErrorT err;

  si2drGroupIdT  rgroup;

  rgroup = si2drGroupFindGroupByName(group,name,"cell",&err);

  return rgroup;
}
// }}}
// locate_pin
// {{{
si2drGroupIdT locate_pin (si2drGroupIdT group, char *name) {
  si2drErrorT err;

  si2drGroupIdT  rgroup;

  rgroup = si2drGroupFindGroupByName(group,name,"pin",&err);

  return rgroup;
}
// }}}
// locate_timing
// {{{
si2drGroupIdT locate_timing (si2drGroupIdT group, char *name) {
  si2drErrorT err;

  si2drGroupIdT  rgroup;

  rgroup = si2drGroupFindGroupByName(group,name,"timing",&err);

  return rgroup;
}
// }}}
// list_attributes
// {{{
//int list_attributes (si2drGroupIdT group) {
//  si2drErrorT err;
//  si2drAttrIdT   at;
//  si2drAttrsIdT  ats = si2drGroupGetAttrs (group, &err);
//
//  while (!si2drObjectIsNull ((at = si2drIterNextAttr (ats, &err)), &err)) {
//    if (si2drAttrGetAttrType (at, &err) == SI2DR_SIMPLE) {
//      printf ("%-25s: ", si2drAttrGetName (at, &err));
//      switch (si2drSimpleAttrGetValueType (at, &err)) {
//        case SI2DR_STRING:  printf ("1: %s\n",si2drSimpleAttrGetStringValue(at,&err)); break;
//        case SI2DR_FLOAT64: printf ("2: %g\n",si2drSimpleAttrGetFloat64Value(at,&err)); break;
//        case SI2DR_INT32:   printf ("3: %d\n",si2drSimpleAttrGetInt32Value(at,&err)); break;
//        case SI2DR_BOOLEAN: printf ("4: %s\n",(si2drSimpleAttrGetBooleanValue(at,&err)?"True":"False")); break;
//        case SI2DR_EXPR:    printf ("5: %s\n",si2drExprToString(si2drSimpleAttrGetExprValue(at,&err),&err)); break;
//      }
//    } else {
//      printf("Complex Value!\n");
//    }
//  }si2drIterQuit (ats, &err);
//}
// }}}
// get_attribute_value
// {{{
//char *get_attribute_value (si2drGroupIdT group, char *name) {
//  si2drErrorT err;
//  char *str;
//  si2drAttrIdT   attr;
//
//	attr = si2drGroupFindAttrByName(group, name, &err);
//
//	if( si2drObjectIsNull(attr,&err) ) {
//    //printf("Error: can't find attribute `%s'.\n", name);
//    str = "NA";
//  } else {
//    if (si2drAttrGetAttrType (attr, &err) == SI2DR_SIMPLE) {
//      //printf ("%-25s: ", si2drAttrGetName (attr, &err));
//      switch (si2drSimpleAttrGetValueType (attr, &err)) {
//        case SI2DR_STRING:  sprintf (str,"1: %s",si2drSimpleAttrGetStringValue(attr,&err)); break;
//        case SI2DR_FLOAT64: sprintf (str,"2: %g",si2drSimpleAttrGetFloat64Value(attr,&err)); break;
//        case SI2DR_INT32:   sprintf (str,"3: %d",si2drSimpleAttrGetInt32Value(attr,&err)); break;
//        case SI2DR_BOOLEAN: sprintf (str,"4: %s",(si2drSimpleAttrGetBooleanValue(attr,&err)?"True":"False")); break;
//        case SI2DR_EXPR:    sprintf (str,"5: %s",si2drExprToString(si2drSimpleAttrGetExprValue(attr,&err),&err)); break;
//      }
//    }
//  }
//  return str;
//}
// }}}
// list_subgroups
// {{{
//int list_subgroups (si2drGroupIdT group) {
//  si2drErrorT err;
//	si2drNamesIdT names;
//  si2drStringT  sname, stype;
//  si2drGroupIdT  gp;
//  group_enum gt;
//  si2drStringT  gtype;
//
//  si2drGroupsIdT groups = si2drGroupGetGroups (group, &err);
//
//	//names = si2drGroupGetNames(group,&err);
//
//  while (!si2drObjectIsNull ((gp = si2drIterNextGroup (groups, &err)), &err)) {
//      sname = get_group_name(gp);
//      stype = si2drGroupGetGroupType(gp, &err);
//      printf("%s: %s\n", stype, sname);
//  } si2drIterQuit (groups, &err);
//
//}
// }}}
// get_subgroups
// {{{
//si2drGroupIdT *get_subgroups (si2drGroupIdT group) {
//  si2drErrorT err;
//	si2drNamesIdT names;
//  si2drStringT  sname, stype;
//  si2drGroupIdT  gp;
//  group_enum gt;
//  si2drStringT  gtype;
//
//  si2drGroupsIdT groups;
//  si2drGroupIdT *gps;
//  int size=0;
//
//// Get the size of groups
//  size = get_subgroups_count(group);
//
//// malloc memory spaces for groups
//  gps = malloc(size * sizeof(si2drGroupIdT));
//
//// Fill-in values i.e. group pointer to array spaces.
//  groups = si2drGroupGetGroups (group, &err);
//  int i=0;
//  while (!si2drObjectIsNull ((gp = si2drIterNextGroup (groups, &err)), &err)) {
//    gps[i] = gp;
//    i++;
//  } si2drIterQuit (groups, &err);
//
//  return gps;
//
//}
// }}}
// get_subgroups_count
// {{{
int get_subgroups_count (si2drGroupIdT group) {
  si2drErrorT err;
  si2drGroupIdT  gp;

  si2drGroupsIdT groups = si2drGroupGetGroups (group, &err);
  int size=0;

// Get the size of groups
  while (!si2drObjectIsNull ((gp = si2drIterNextGroup (groups, &err)), &err)) {
      size++;
  } si2drIterQuit (groups, &err);

  return size;

}
// }}}
// index_group
// {{{
si2drGroupIdT index_group (si2drGroupIdT group, int index) {
  si2drErrorT err;
  si2drGroupIdT  gp;
  si2drGroupsIdT groups;
  int i = 0;

  groups = si2drGroupGetGroups (group, &err);

  while (!si2drObjectIsNull ((gp = si2drIterNextGroup (groups, &err)), &err)) {
    //printf("%d\n", i);
    if (i == index) {
      break;
    }
    i++;
  } si2drIterQuit (groups, &err);

  return gp;
}
// }}}
// new_err
// {{{
si2drErrorT *new_err () {
  si2drErrorT *err = malloc(sizeof(si2drErrorT));
  return err;
}
// }}}
// new_vtype
// {{{
si2drValueTypeT *new_vtype () {
  si2drValueTypeT *re = malloc(sizeof(si2drValueTypeT));
  return re;
}
// }}}
// get_vtype_value
// {{{
si2drValueTypeT get_vtype_value (si2drValueTypeT *vtype) {
  return *vtype;
}
// }}}
// new_int32
// {{{
si2drInt32T *new_int32 () {
  si2drInt32T *re = malloc(sizeof(si2drInt32T));
  return re;
}
// }}}
// new_float64
// {{{
si2drFloat64T *new_float64 () {
  si2drFloat64T *re = malloc(sizeof(si2drFloat64T));
  return re;
}
// }}}
// new_string
// {{{
si2drStringT *new_string () {
  si2drStringT *re = malloc(sizeof(si2drStringT));
  return re;
}
// }}}
// get_string_value
// {{{
si2drStringT get_string_value (si2drStringT *pt) {
  return *pt;
}
// }}}
// get_float64_value
// {{{
si2drFloat64T get_float64_value (si2drFloat64T *pt) {
  return *pt;
}
// }}}
// get_int32
// {{{
si2drInt32T get_int32_value (si2drInt32T *pt) {
  return *pt;
}
// }}}
// new_boolean
// {{{
si2drBooleanT *new_boolean () {
  si2drBooleanT *re = malloc(sizeof(si2drBooleanT));
  return re;
}
// }}}
// new_expr
// {{{
si2drExprT **new_expr () {
  si2drExprT **re = malloc(sizeof(si2drExprT));
  return re;
}
// }}}
// vim:ft=lip fdm=marker

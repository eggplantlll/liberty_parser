%module lip
%{
#include <si2dr_liberty.h>
//extern si2drErrorT err;
extern si2drGroupIdT read_lib (char *filename) ;
extern si2drStringT get_group_name (si2drGroupIdT group) ;
extern si2drGroupIdT locate_cell (si2drGroupIdT group, char *name);
extern si2drGroupIdT locate_pin  (si2drGroupIdT group, char *name);
extern si2drGroupIdT locate_timing  (si2drGroupIdT group, char *name);
//extern int list_attributes (si2drGroupIdT group);
//extern int list_subgroups (si2drGroupIdT group);
//extern si2drGroupIdT *get_subgroups (si2drGroupIdT group);
extern si2drGroupIdT index_group (si2drGroupIdT group, int index);
extern int get_subgroups_count (si2drGroupIdT group);
extern si2drStringT get_group_type (si2drGroupIdT group);
//extern char *get_attribute_value (si2drGroupIdT group, char *name);
extern si2drErrorT *new_err ();
extern si2drValueTypeT *new_vtype ();
extern si2drInt32T *new_int32 ();
extern si2drFloat64T *new_float64 ();
extern si2drStringT *new_string ();
extern si2drBooleanT *new_boolean ();
extern si2drExprT **new_expr ();
extern si2drValueTypeT get_vtype_value (si2drValueTypeT *vtype);
extern si2drStringT get_string_value (si2drStringT *pt);
extern si2drFloat64T get_float64_value (si2drFloat64T *pt);
extern si2drInt32T get_int32_value (si2drInt32T *pt);
%}

// Just grab the gd.h header file
%include si2dr_liberty.h

// Plus a few file I/O functions (to be explained shortly)
//FILE *fopen(char *filename, char *mode);
//void fclose(FILE *f);

//extern si2drErrorT err;
extern si2drGroupIdT read_lib (char *filename) ;
extern si2drStringT  get_group_name (si2drGroupIdT group) ;
extern si2drGroupIdT locate_cell (si2drGroupIdT group, char *name);
extern si2drGroupIdT locate_pin  (si2drGroupIdT group, char *name);
extern si2drGroupIdT locate_timing  (si2drGroupIdT group, char *name);
//extern int list_attributes (si2drGroupIdT group);
//extern int list_subgroups (si2drGroupIdT group);
//extern si2drGroupIdT *get_subgroups (si2drGroupIdT group);
extern si2drGroupIdT index_group (si2drGroupIdT group, int index);
extern int get_subgroups_count (si2drGroupIdT group);
extern si2drStringT get_group_type (si2drGroupIdT group);
//extern char *get_attribute_value (si2drGroupIdT group, char *name);
extern si2drErrorT *new_err ();
extern si2drValueTypeT *new_vtype ();
extern si2drInt32T *new_int32 ();
extern si2drFloat64T *new_float64 ();
extern si2drStringT *new_string ();
extern si2drBooleanT *new_boolean ();
extern si2drExprT **new_expr ();
extern si2drValueTypeT get_vtype_value (si2drValueTypeT *vtype);
extern si2drStringT get_string_value (si2drStringT *pt);
extern si2drFloat64T get_float64_value (si2drFloat64T *pt);
extern si2drInt32T get_int32_value (si2drInt32T *pt);

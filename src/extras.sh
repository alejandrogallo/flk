_str_replace () {
  local s="${ANON["${1}"]}"; shift
  local f="${ANON["${1}"]}"; shift
  local x="${ANON["${1}"]}"; shift
  _string "${s//${f}/${x}}"
}

_fref "str-replace" _str_replace

_str_split() {
  local var="${ANON["${1}"]}"; shift
  local ifs="${ANON["${1}"]}"; shift
  _list
  local newlist="${r}"

  while IFS="${ifs}" read -ra _str_split_arr; do
    for _str_split_itm in "${_str_split_arr[@]}"; do
      _string "${_str_split_itm}";
      _conj! "${newlist}" "${r}";
    done
  done <<< "${var}"
  r="${newlist}"
}

_fref "str-split" _str_split

_str_pos() {
  local haystack="${ANON["${1}"]}"; shift
  local needle="${ANON["${1}"]}"; shift
  local pos="${haystack%%$needle*}"
  [[ "$pos" == "$haystack" ]] && _number "-1" || _number "${#pos}"
}

_fref "str-pos" _str_pos

_env() {
  local key
  local val
  [ "${1}" != "" ] && key="${ANON["${1}"]}"; shift
  [ "${1}" != "" ] && val="${ANON["${1}"]}"; shift
  [ "${val}" != "" ] && export "${key}=${val}"
  local line
  local ikey
  local ival

  _hash_map; local envmap="${r}"
  while read -r -d '' line; do
    IFS='=' read ikey ival <<< "${line}"
    _string "${ival}"
    _assoc! "${envmap}" "${ikey}" "${r}"
  done < <(env -0)

  if [ "${key}" != "" ]
  then
    _get "${envmap}" "${key}"
    [[ "${r}" ]] || r="${__nil}"
  else
    r="${envmap}"
  fi
}

_fref "env" _env

_sh_BANG() {
  local args=""
  local t_std=""
  local t_err=""
  local t_ret=0
  local cmd="${ANON["${1}"]}"; shift
  [ "${1}" != "" ] && args="${ANON["${1}"]}"; shift

  local cmdargs="${cmd}"
  for _arg in ${args}; do
    cmdargs="$cmdargs ${ANON["${_arg}"]}";
  done

  eval "$( eval "$cmdargs" 2> >(t_err=$(cat); typeset -p t_err) > >(t_std=$(cat); typeset -p t_std); t_ret=$?; typeset -p t_ret );";

  _list
  local newlist="${r}"

  _string "$t_std";
  _conj! "${newlist}" "${r}";

  _string "$t_err"
  _conj! "${newlist}" "${r}";

  _number "$t_ret"
  _conj! "${newlist}" "${r}";

  r="${newlist}"
}

_fref "sh!" _sh_BANG

_remove_hashbang() {
  src="${ANON["${1}"]}"
  _string "${src/*flk$'\n'/}"
}

_fref "remove-hashbang" _remove_hashbang

_fref "last" _last

REP "(def! load-file-without-hashbang (fn* (f) (eval (read-string (str \"(do \" (remove-hashbang (slurp f) ) \"\nnil)\")))))"

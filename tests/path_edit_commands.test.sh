#!/usr/bin/env zsh

# setup #######################################################################

source ${0:a:h}/unit.sh

local original_path="$PATH"

# load_path_ethic #############################################################
funciton test_load_path_ethic() {
  before_each

  local default_preset_path="$HOME/.path-ethic/default.preset"
  local saved_push_path=$(existing_dir_from $HOME/saved_push)
  local saved_append_path=$(existing_dir_from $HOME/saved_append)

  echo "PATH_ETHIC_HEAD=\"\$HOME/saved_push\"" >$default_preset_path
  echo "PATH_ETHIC_TAIL=\"\$HOME/saved_append\"" >>$default_preset_path

  load_path_ethic

  assert_equals $PATH_ETHIC_HEAD "$saved_push_path"
  assert_equals $PATH_ETHIC_TAIL "$saved_append_path"
  assert_equals $PATH "$saved_push_path:$original_path:$saved_append_path"
}

# peth list ##################################################################
function test_path_list() {
  before_each

  local listed_path=$(peth list |  tr '\n' ':' | rev | cut -c2- | rev)

  assert_not_empty "$listed_path"
  assert_equals $listed_path $PATH
}

# peth reset ##################################################################
function test_peth_reset() {
  before_each

  local push_path=$(mktemp -d)
  local append_path=$(mktemp -d)

  peth push $push_path
  peth append $append_path

  peth reset

  assert_equals $PATH_ETHIC_HEAD ""
  assert_equals $PATH_ETHIC_TAIL ""
  assert_equals $PATH $original_path
}

# peth push ###################################################################
function test_peth_push() {
  before_each

  local push_path=$(mktemp -d)

  peth push $push_path

  assert_equals $PATH_ETHIC_HEAD $push_path
  assert_equals $PATH_ETHIC_TAIL ""
}

# peth append #################################################################
function test_peth_append() {
  before_each

  local append_path=$(mktemp -d)

  peth append $append_path

  assert_equals $PATH_ETHIC_TAIL $append_path
  assert_equals $PATH_ETHIC_HEAD ""
}

# peth flip #####################################################################
function test_peth_flip() {
  before_each

  local push_path=$(mktemp -d)
  local append_path=$(mktemp -d)

  peth push $push_path
  peth append $append_path

  peth flip

  assert_equals $PATH_ETHIC_HEAD $append_path
  assert_equals $PATH_ETHIC_TAIL $push_path
  assert_equals $PATH $append_path:$original_path:$push_path
}

# peth rm #####################################################################
function test_peth_rm(){
  before_each

  local push_path=$(mktemp -d)
  local append_path=$(mktemp -d)

  peth push $push_path
  peth append $append_path

  peth rm $push_path
  peth rm $append_path

  assert_equals $PATH_ETHIC_HEAD ""
  assert_equals $PATH_ETHIC_TAIL ""
  assert_equals $PATH $original_path
}

#
# run all tests
#

test_load_path_ethic
test_path_list
test_peth_reset
test_peth_push
test_peth_append
test_peth_flip

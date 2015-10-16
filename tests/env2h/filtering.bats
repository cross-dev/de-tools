#!/usr/bin/env bats

ENV2H=${BATS_TEST_DIRNAME}/../../env2h

setup() {
    export CONFIG_SOMETHING=y
    export CONFIG_SOMETHING_ELSE=y
    export CONFIG_DECIMAL=5
    export CONFIG_HEXADECIMAL=0xdeadbeef
    export CONFIG_STRING=\"abcdefghz\"
}

defined() {
    for D in "$@"
    do
        echo "#ifndef ${D}"
        echo "#error ${D} not defined"
        echo "#endif"
    done
}

undefined() {
    for D in "$@"
    do
        echo "#ifdef ${D}"
        echo "#error ${D} defined"
        echo "#endif"
    done
}

get_value() {
    for D in "$@"
    do
        (${ENV2H} "^${D}\$" && echo ${D}) | cpp -E | awk 'NF {if ($1 != "#") print $0}'
    done
}

@test 'Filtering works' {
    run cpp -E <(${ENV2H} '^CONFIG_.+' && defined CONFIG_SOMETHING)
    [ "${status}" -eq "0" ]
}

@test 'Filter multiple' {
    run cpp -E <(${ENV2H} '^CONFIG_SOMETHING.*' && defined CONFIG_SOMETHING && defined CONFIG_SOMETHING_ELSE)
    [ "${status}" -eq "0" ]
}

@test 'Filtering is selective' {
    run cpp -E <(${ENV2H} '^CONFIG_SOMETHING$' && defined CONFIG_SOMETHING && undefined CONFIG_SOMETHING_ELSE)
    [ "${status}" -eq "0" ]
}

@test 'Get decimal' {
    run get_value CONFIG_DECIMAL
    [ "${status}" -eq "0" ]
    [ "${output}" -eq "5" ]
}

@test 'Get hexadecimal' {
    run get_value CONFIG_HEXADECIMAL
    [ "${status}" -eq "0" ]
    [ "${output}" = "0xdeadbeef" ]
}

@test 'Get string' {
    run get_value CONFIG_STRING
    [ "${status}" -eq "0" ]
    [ "${output}" = \"abcdefghz\" ]
}


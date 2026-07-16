#!/bin/bash

source /usr/lib/openfoam/openfoam2412/etc/bashrc

BC=$1

if [ "$BC" == "parallel" ]; then
    cp -r 0.parallel 0
elif [ "$BC" == "perpendicular" ]; then
    cp -r 0.perpendicular 0
else
    echo "Error: Input variable must be 'parallel' or 'perpendicular'"
    exit 1
fi

blockMesh

RKSymMagBuoyantFoam

touch p.foam

# -----------------------------------
# Validation
# -----------------------------------

Gr=10000
Ha=500
nu=0.001

if [ "$BC" = "perpendicular" ]; then
    res_an=$(awk -v Gr="$Gr" -v Ha="$Ha" \
        'BEGIN {printf "%.12g", Gr/(2*Ha)}')

    tensor_component=7

else
    res_an=$(awk -v Gr="$Gr" -v Ha="$Ha" \
        'BEGIN {printf "%.12g", Gr/(Ha*Ha)}')

    tensor_component=4
fi

probe_file=$(find postProcessing/sampleB -type f -name 'grad(U)' \
    | sort -V | tail -n 1)

if [ -z "$probe_file" ] || [ ! -f "$probe_file" ]; then
    echo "Error: Probe file grad(U) not found in postProcessing/sampleB"
    exit 1
fi

component_value=$(
    awk -v component="$tensor_component" '
        !/^#/ && NF > 0 {
            line = $0
        }
        END {
            gsub(/[()]/, "", line)
            split(line, values)

            # First value is time.
            # Therefore tensor component N is at index N+1.
            print values[component + 1]
        }
    ' "$probe_file"
)

if [ -z "$component_value" ]; then
    echo "Error: Could not extract component $tensor_component from:"
    echo "$probe_file"
    exit 1
fi

res_num=$(awk -v value="$component_value" -v nu="$nu" \
    'BEGIN {printf "%.12g", value/nu}')

echo
echo "Validation results"
echo "------------------"
echo "Boundary condition  = $BC"
echo "Probe file          = $probe_file"
echo "Tensor component    = $tensor_component"
echo "Analytical solution = $res_an"
echo "Numerical solution  = $res_num"

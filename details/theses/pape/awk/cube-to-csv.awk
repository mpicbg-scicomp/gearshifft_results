#!/usr/bin/awk -f

BEGIN {
    OFS = ","
    print "id", "run", "region", "PAPI_DP_OPS"
}

NF < 7 { next }

NF == 7 {
    region = $NF
    id = -1
}

NF > 7 {
    sub("instance=", "", $NF)
    run = ($NF - 1) % 20
    if (run == 0) { id += 1 }
    print id, run, region, $2
}

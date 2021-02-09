#!/usr/bin/awk -f

BEGIN {
    FS = ","
    OFS = ","
}

# throw away header
NR == 1 { next }

{
    id     = $1
    run    = $2
    region = $3
    flops  = $4

    sub(/plan_backward.*/, "plan_backward", region)

    data[id, run, region] = flops
}

END {
    print "id",
          "run",
          "FLOPs_plan_forward",
          "FLOPs_plan_backward",
          "FLOPs_transform_forward",
          "FLOPs_transform_backward"

    for (id = 0; id < num_ids; id++) {
        for (run = 0; run < 20; run++) {
            print id,
                  run,
                  data[id, run, "plan_forward"],
                  data[id, run, "plan_backward"],
                  data[id, run, "transform_forward"],
                  data[id, run, "transform_backward"]
        }
    }
}

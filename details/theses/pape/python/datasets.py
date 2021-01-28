
# [ filename, case, roundtrip?, datasets ]

sets = [
    [
        "case1", "SAXS", False,
        [
            [
                ("Skylake FFTW", "data/normal-case1-skylake-fftw-3002508-01.csv",         "x", "--"),
                ("Skylake MKL",  "data/normal-case1-skylake-fftwwrappers-3002508-01.csv", "x", "-")
            ],

            [
                ("POWER9 FFTW", "data/normal-case1-power9-fftw-4696784-01.csv",     "o", "--"),
                ("POWER9 ESSL", "data/normal-case1-power9-esslfftw-4696784-01.csv", "o", "-")
            ],

            [
                ("Hi1616 FFTW",  "data/normal-case1-hi1616-fftw-15177-01.csv",      "^", "--"),
                ("Hi1616 ArmPL", "data/normal-case1-hi1616-armplfftw-15177-01.csv", "^", "-")
            ]
        ]
    ],
    [
        "case2", "Schrödinger", True,
        [
            [
                ("Skylake FFTW", "data/normal-case2-skylake-fftw-3002508-01.csv",         "x", "--"),
                ("Skylake MKL",  "data/normal-case2-skylake-fftwwrappers-3002508-01.csv", "x", "-")
            ],

            [
                ("POWER9 FFTW", "data/normal-case2-power9-fftw-4696784-01.csv",     "o", "--"),
                ("POWER9 ESSL", "data/normal-case2-power9-esslfftw-4696784-01.csv", "o", "-")
            ],

            [
                ("Hi1616 FFTW",  "data/normal-case2-hi1616-fftw-15177-01.csv",      "^", "--"),
                ("Hi1616 ArmPL", "data/normal-case2-hi1616-armplfftw-15177-01.csv", "^", "-")
            ]
        ]
    ],
    [
        "case3", "Ab-initio", True,
        [
            [
                ("Skylake FFTW", "data/normal-case3-skylake-fftw-3002508-01.csv",         "x", "--"),
                ("Skylake MKL",  "data/normal-case3-skylake-fftwwrappers-3002508-01.csv", "x", "-")
            ],

            [
                ("POWER9 FFTW", "data/normal-case3-power9-fftw-4696784-01.csv",     "o", "--"),
                ("POWER9 ESSL", "data/normal-case3-power9-esslfftw-4696784-01.csv", "o", "-")
            ],

            [
                ("Hi1616 FFTW",  "data/normal-case3-hi1616-fftw-15177-01.csv",      "^", "--"),
                ("Hi1616 ArmPL", "data/normal-case3-hi1616-armplfftw-15177-01.csv", "^", "-")
            ]
        ]
    ],
    [
        "case3-cold", "Ab-initio (Cold)", True,
        [
            [
                ("Skylake FFTW", "data/normal-case3-cold-skylake-fftw-3013366.merged.csv",         "x", "--"),
                ("Skylake MKL",  "data/normal-case3-cold-skylake-fftwwrappers-3013366.merged.csv", "x", "-")
            ],

            [
                ("POWER9 FFTW", "data/normal-case3-cold-power9-fftw-5015597.merged.csv",     "o", "--"),
                ("POWER9 ESSL", "data/normal-case3-cold-power9-esslfftw-5015597.merged.csv", "o", "-")
            ],

            [
                ("Hi1616 FFTW",  "data/normal-case3-cold-hi1616-fftw-15440.merged.csv",      "^", "--"),
                ("Hi1616 ArmPL", "data/normal-case3-cold-hi1616-armplfftw-15440.merged.csv", "^", "-")
            ]
        ]
    ]
]

sets_flops = [
    [
        "case1", "SAXS", False, 0.1,
        [
            [
                ("Skylake FFTW", "data/scorep-case1-skylake-fftw-3002506-01{}.csv",         "x", "--"),
                ("Skylake MKL",  "data/scorep-case1-skylake-fftwwrappers-3002506-01{}.csv", "x", "-")
            ],

            [
                ("POWER9 FFTW", "data/scorep-case1-power9-fftw-4696785-01{}.csv",     "o", "--"),
                ("POWER9 ESSL", "data/scorep-case1-power9-esslfftw-4696785-01{}.csv", "o", "-")
            ]
        ]
    ],
    [
        "case2", "Schrödinger", True, 7.0,
        [
            [
                ("Skylake FFTW", "data/scorep-case2-skylake-fftw-3002506-01{}.csv",         "x", "--"),
                ("Skylake MKL",  "data/scorep-case2-skylake-fftwwrappers-3002506-01{}.csv", "x", "-")
            ],

            [
                ("POWER9 FFTW", "data/scorep-case2-power9-fftw-4696785-01{}.csv",     "o", "--"),
                ("POWER9 ESSL", "data/scorep-case2-power9-esslfftw-4696785-01{}.csv", "o", "-")
            ]
        ]
    ],
    [
        "case3", "Ab-initio", True, 0.5,
        [
            [
                ("Skylake FFTW", "data/scorep-case3-skylake-fftw-3002506-01{}.csv",         "x", "--"),
                ("Skylake MKL",  "data/scorep-case3-skylake-fftwwrappers-3002506-01{}.csv", "x", "-")
            ],

            [
                ("POWER9 FFTW", "data/scorep-case3-power9-fftw-4696785-01{}.csv",     "o", "--"),
                ("POWER9 ESSL", "data/scorep-case3-power9-esslfftw-4696785-01{}.csv", "o", "-")
            ]
        ]
    ],
    [
        "case3-cold", "Ab-initio (Cold)", True, 0.5,
        [
            [
                ("Skylake FFTW", "data/scorep-case3-cold-skylake-fftw-3013366{}.merged.csv",         "x", "--"),
                ("Skylake MKL",  "data/scorep-case3-cold-skylake-fftwwrappers-3013366{}.merged.csv", "x", "-")
            ],

            [
                ("POWER9 FFTW", "data/scorep-case3-cold-power9-fftw-5015597{}.merged.csv",     "o", "--"),
                ("POWER9 ESSL", "data/scorep-case3-cold-power9-esslfftw-5015597{}.merged.csv", "o", "-")
            ]
        ]
    ]
]

sets_smt = [
    [
        "smt", "", False,
        [
            [
                ("SMT-1", "data-power9-smt1/normal-case1-power9-fftw-4546553-01.csv", "o", "-")
            ],
            [
                ("SMT-2", "data-power9-smt2/normal-case1-power9-fftw-4546941-01.csv", "o", "-")
            ],
            [
                ("SMT-4", "data-power9-smt4/normal-case1-power9-fftw-4321118-01.csv", "o", "-")
            ]
        ]
    ]
]

info_by_case = {
    # case:   [for filename, roundtrip?, factor_a]
    "SAXS": ["case1", False, 0.1],
    "Schrödinger": ["case2", True, 7.0],
    "Ab-initio": ["case3", True, 0.5],
    "Ab-initio (Cold)": ["case3-cold", True, 0.5],
}

info_by_arch = {
    # arch: [marker]
    "Skylake": ["x"],
    "POWER9": ["o"],
    "Hi1616": ["^"],
}

sets_by_arch = {
    "Skylake": {
        "SAXS": {
            "FFTW": "data/scorep-case1-skylake-fftw-3002506-01{}.csv",
            "MKL":  "data/scorep-case1-skylake-fftwwrappers-3002506-01{}.csv",
        },
        "Schrödinger": {
            "FFTW": "data/scorep-case2-skylake-fftw-3002506-01{}.csv",
            "MKL":  "data/scorep-case2-skylake-fftwwrappers-3002506-01{}.csv",
        },
        "Ab-initio": {
            "FFTW": "data/scorep-case3-skylake-fftw-3002506-01{}.csv",
            "MKL":  "data/scorep-case3-skylake-fftwwrappers-3002506-01{}.csv",
        },
        "Ab-initio (Cold)": {
            "FFTW": "data/scorep-case3-cold-skylake-fftw-3013366{}.merged.csv",
            "MKL":  "data/scorep-case3-cold-skylake-fftwwrappers-3013366{}.merged.csv",
        }
    },
    "POWER9": {
        "SAXS": {
            "FFTW": "data/scorep-case1-power9-fftw-4696785-01{}.csv",
            "ESSL": "data/scorep-case1-power9-esslfftw-4696785-01{}.csv",
        },
        "Schrödinger": {
            "FFTW": "data/scorep-case2-power9-fftw-4696785-01{}.csv",
            "ESSL": "data/scorep-case2-power9-esslfftw-4696785-01{}.csv",
        },
        "Ab-initio": {
            "FFTW": "data/scorep-case3-power9-fftw-4696785-01{}.csv",
            "ESSL": "data/scorep-case3-power9-esslfftw-4696785-01{}.csv",
        },
        "Ab-initio (Cold)": {
            "FFTW": "data/scorep-case3-cold-power9-fftw-5015597{}.merged.csv",
            "ESSL": "data/scorep-case3-cold-power9-esslfftw-5015597{}.merged.csv",
        }
    },
    "Hi1616": {
        "SAXS": {
            "FFTW":  "data/normal-case1-hi1616-fftw-15177-01{}.csv",
            "ARMPL": "data/normal-case1-hi1616-armplfftw-15177-01{}.csv",
        },
        "Schrödinger": {
            "FFTW":  "data/normal-case2-hi1616-fftw-15177-01{}.csv",
            "ARMPL": "data/normal-case2-hi1616-armplfftw-15177-01{}.csv",
        },
        "Ab-initio": {
            "FFTW":  "data/normal-case3-hi1616-fftw-15177-01{}.csv",
            "ARMPL": "data/normal-case3-hi1616-armplfftw-15177-01{}.csv",
        },
        "Ab-initio (Cold)": {
            "FFTW":  "data/normal-case3-cold-hi1616-fftw-15440{}.merged.csv",
            "ARMPL": "data/normal-case3-cold-hi1616-armplfftw-15440{}.merged.csv",
        }
    },
}

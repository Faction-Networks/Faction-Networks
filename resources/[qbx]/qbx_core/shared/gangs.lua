---Gang names must be lower case (top level table key)
---@type table<string, Gang>
return {
    ['none'] = {
        label = 'No Gang',
        grades = {
            [0] = {
                name = 'Unaffiliated'
            },
        },
    },
    ['hwp'] = {
        label = 'Highway Patrol',
        grades = {
            [0] = {
                name = 'Member'
            },
            [1] = {
                name = 'Supervisor'
            },
        },
    },
    ['ciu'] = {
        label = 'Crime Investigation Unit',
        grades = {
            [0] = {
                name = 'Member'
            },
            [1] = {
                name = 'Supervisor'
            },
        },
    },
    ['cirt'] = {
        label = 'Critical Incident Response Team',
        grades = {
            [0] = {
                name = 'Member'
            },
            [1] = {
                name = 'Supervisor'
            },
        },
    },
    ['port'] = {
        label = 'Public Order Response Team',
        grades = {
            [0] = {
                name = 'Member'
            },
            [1] = {
                name = 'Supervisor'
            },
        },
    },
    ['families'] = {
        label = 'Families',
        grades = {
            [0] = {
                name = 'Recruit'
            },
            [1] = {
                name = 'Enforcer'
            },
            [2] = {
                name = 'Shot Caller'
            },
            [3] = {
                name = 'Boss',
                isboss = true,
                bankAuth = true
            },
        },
    },
    ['triads'] = {
        label = 'Triads',
        grades = {
            [0] = {
                name = 'Recruit'
            },
            [1] = {
                name = 'Enforcer'
            },
            [2] = {
                name = 'Shot Caller'
            },
            [3] = {
                name = 'Boss',
                isboss = true,
                bankAuth = true
            },
        },
    }
}

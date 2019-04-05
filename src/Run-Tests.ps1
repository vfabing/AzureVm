$env:TASK_TEST_TRACE=1
tsc --build azVmManagerTask/tsconfig.json
mocha azVmManagerTask/tests/_suite.js
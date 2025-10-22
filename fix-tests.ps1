# --- Step 1: Replace old expectations with new helpers ---

Get-ChildItem -Path .\test -Recurse -Include *.dart | ForEach-Object {
    (Get-Content $_.FullName) `
    -replace "throwsArgumentError", "throwsCardNotInHand()" `
    -replace "throwsA<GameError>\(\)", "throwsAnyGameError()" |
    Set-Content $_.FullName
}

# --- Step 2: Fix import paths for test_utils.dart ---

# Tests directly under test/ (e.g. test/game_test.dart, test/widget_test.dart, test/fakes.dart)
Get-ChildItem -Path .\test -File -Filter *.dart | ForEach-Object {
    (Get-Content $_.FullName) -replace "import '.*test_utils.dart';", "import 'test_utils.dart';" |
    Set-Content $_.FullName
}

# Tests one folder deep (game_logic, models, services)
Get-ChildItem -Path .\test\* -Directory | Where-Object { $_.Name -ne "integration" } | ForEach-Object {
    Get-ChildItem -Path $_.FullName -File -Filter *.dart | ForEach-Object {
        (Get-Content $_.FullName) -replace "import '.*test_utils.dart';", "import '../test_utils.dart';" |
        Set-Content $_.FullName
    }
}

# Tests two folders deep (integration)
Get-ChildItem -Path .\test\integration -File -Filter *.dart | ForEach-Object {
    (Get-Content $_.FullName) -replace "import '.*test_utils.dart';", "import '../../test_utils.dart';" |
    Set-Content $_.FullName
}
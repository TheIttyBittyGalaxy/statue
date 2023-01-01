local function directory_contents(dir)
    local contents = {}
    do
        local directory_listing = io.popen('dir "' .. dir .. '" /b')
        if not directory_listing then
            error("Could not open tests directory")
        end
        for directory in directory_listing:lines() do
            table.insert(contents, directory)
        end
        directory_listing:close()
    end

    table.sort(contents)
    return contents
end

local tally = 0;
local success_tally = 0
local skipped_tally = 0
local failed_tally = 0

print()
for _, category in ipairs(directory_contents("../tests")) do
    print(category)
    print(("="):rep(category:len()))
    for _, file_name in ipairs(directory_contents("../tests/" .. category)) do
        local test_success = true
        local test_skipped = false
        local expect_compiler_success = true
        local expectation = {}

        local name = file_name:sub(0, -8)
        local file_path = "../tests/" .. category .. "/" .. file_name
        local result_path = "local/test-results/" .. category .. "-" .. name

        -- Parse expectation
        do
            local file = io.open(file_path, "r")
            if not file then
                error("Unable to open " .. file_path)
            end

            local first_line = true
            for line in file:lines() do
                if first_line then
                    if line == "// EXPECT ERROR" then
                        expect_compiler_success = false
                        break
                    elseif line ~= "// EXPECT:" then
                        test_skipped = true
                        break
                    end

                    first_line = false
                else
                    table.insert(expectation, line:sub(4))
                end
            end
            file:close()
        end

        -- Test program
        if not test_skipped then
            -- Run program
            -- Information about how this command is outputting the result is aailable at https://helpdeskgeek.com/how-to/redirect-output-from-command-line-to-text-file/
            local compiler_succeeded = os.execute('lua54 main.lua "' .. file_path .. '" 1> "' .. result_path .. '" 2>&1')
            compiler_succeeded = compiler_succeeded == true

            if expect_compiler_success ~= compiler_succeeded then
                test_success = false

            elseif expect_compiler_success then
                -- Get result
                local result, err = io.open(result_path)
                if not result then
                    error("Could not read result of program compilation (" .. err .. ")")
                end

                -- Compare result to expectation
                local i = 1
                for line in result:lines() do
                    if line ~= expectation[i] then
                        test_success = false
                        break
                    end
                    i = i + 1
                end
                -- FIXME: Address situations where the length of the expectation is different to the length of the result

                result:close()
            end
        end

        -- Display result
        tally = tally + 1
        if test_skipped then
            skipped_tally = skipped_tally + 1
        elseif test_success then
            success_tally = success_tally + 1
        else
            failed_tally = failed_tally + 1
        end
        print((test_skipped and "? " or (test_success and "✓ " or "✗ ")) .. name)
    end
    print()
end

print("SUCCESS: " .. success_tally .. " / " .. tally)
print("FAILED:  " .. failed_tally .. " / " .. tally)
print("SKIPPED: " .. skipped_tally .. " / " .. tally)

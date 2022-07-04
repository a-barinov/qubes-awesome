config.id = 'Unknown'

for line in io.lines('/proc/cpuinfo') do
    if line:find('i5-1130G7', 0, true) then
        config.id = 'OneMix4'
        break
    end
end

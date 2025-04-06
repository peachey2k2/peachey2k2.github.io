window.INI = {
  parse: function(iniText) {
    const lines = iniText.split(/[\r\n]+/);
    const result = {};
    let currentSection = result;
    
    lines.forEach(line => {
        line = line.trim();
        if (!line || line.startsWith(';')) return;
        
        // Handle sections
        const sectionMatch = line.match(/^\[([^\]]+)\]$/);
        if (sectionMatch) {
            result[sectionMatch[1]] = {};
            currentSection = result[sectionMatch[1]];
            return;
        }
        
        // Handle key-value pairs
        const keyValueMatch = line.match(/^([^=]+)=(.*)$/);
        if (keyValueMatch) {
            const key = keyValueMatch[1].trim();
            const value = keyValueMatch[2].trim();
            
            // Convert to number if possible
            currentSection[key] = isNaN(value) ? value : Number(value);
            
            // Convert 'true'/'false' to boolean
            if (value.toLowerCase() === 'true') currentSection[key] = true;
            if (value.toLowerCase() === 'false') currentSection[key] = false;
        }
    });
    
    return result;
  }
};

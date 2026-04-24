#!/usr/bin/env node
/**
 * Sequon Selector - Phase 1 Implementation
 * Selects random sequons from lexasome files
 */

const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const { Readable } = require('stream');

// Base directory for lexasomes
const LEXASOME_BASE = path.join(__dirname, '..', 'lexasomes');

/**
 * Select random sequons from a text file
 * @param {string} filepath - Path to .txt file
 * @param {number} count - Number of sequons to select
 * @returns {Promise<string[]>} Selected sequons
 */
async function selectFromTxt(filepath, count = 1) {
    try {
        const content = fs.readFileSync(filepath, 'utf8');
        const lines = content.split('\n')
            .map(line => line.trim())
            .filter(line => line.length > 0 && !line.startsWith('#'));
        
        if (lines.length === 0) {
            throw new Error(`No sequons found in ${filepath}`);
        }
        
        // Simple random selection
        const selected = [];
        for (let i = 0; i < count && i < lines.length; i++) {
            const randomIndex = Math.floor(Math.random() * lines.length);
            selected.push(lines[randomIndex]);
        }
        
        return selected;
    } catch (error) {
        console.error(`Error reading text file ${filepath}:`, error.message);
        throw error;
    }
}

/**
 * Select weighted sequons from a CSV file
 * @param {string} filepath - Path to .csv file
 * @param {number} count - Number of sequons to select
 * @returns {Promise<string[]>} Selected sequons
 */
async function selectFromCsv(filepath, count = 1) {
    return new Promise((resolve, reject) => {
        const sequons = [];
        const weights = [];
        
        fs.createReadStream(filepath)
            .pipe(csv())
            .on('data', (row) => {
                // Expecting columns: constraint,weight
                if (row.constraint && row.weight) {
                    sequons.push(row.constraint);
                    weights.push(parseFloat(row.weight));
                }
            })
            .on('end', () => {
                if (sequons.length === 0) {
                    reject(new Error(`No sequons found in ${filepath}`));
                    return;
                }
                
                // Weighted random selection
                const selected = [];
                for (let i = 0; i < count; i++) {
                    const totalWeight = weights.reduce((a, b) => a + b, 0);
                    let random = Math.random() * totalWeight;
                    
                    for (let j = 0; j < sequons.length; j++) {
                        random -= weights[j];
                        if (random <= 0) {
                            selected.push(sequons[j]);
                            break;
                        }
                    }
                }
                
                resolve(selected);
            })
            .on('error', (error) => {
                reject(new Error(`Error reading CSV file ${filepath}: ${error.message}`));
            });
    });
}

/**
 * Select from JSON file (simple implementation for Phase 1)
 * @param {string} filepath - Path to .json file
 * @param {string} path - JSON path to select from
 * @param {number} count - Number of items to select
 * @returns {Promise<any[]>} Selected items
 */
async function selectFromJson(filepath, jsonPath = '', count = 1) {
    try {
        const content = fs.readFileSync(filepath, 'utf8');
        const data = JSON.parse(content);
        
        // Simple path resolution for Phase 1
        let targetArray;
        if (jsonPath === 'models') {
            targetArray = data.models || [];
        } else if (jsonPath === 'selection_rules') {
            // For rules, we return the object
            return [data.selection_rules || {}];
        } else {
            // Default: try to find an array
            targetArray = Array.isArray(data) ? data : Object.values(data).find(v => Array.isArray(v)) || [];
        }
        
        if (!Array.isArray(targetArray) || targetArray.length === 0) {
            throw new Error(`No array found at path ${jsonPath} in ${filepath}`);
        }
        
        // Random selection from array
        const selected = [];
        for (let i = 0; i < count && i < targetArray.length; i++) {
            const randomIndex = Math.floor(Math.random() * targetArray.length);
            selected.push(targetArray[randomIndex]);
        }
        
        return selected;
    } catch (error) {
        console.error(`Error reading JSON file ${filepath}:`, error.message);
        throw error;
    }
}

/**
 * Main sequon selector function
 * @param {string} relativePath - Relative path from lexasomes directory
 * @param {number} count - Number of sequons to select
 * @param {string} jsonPath - Optional JSON path for .json files
 * @returns {Promise<object>} Selection result
 */
async function selectSequons(relativePath, count = 1, jsonPath = '') {
    const filepath = path.join(LEXASOME_BASE, relativePath);
    
    if (!fs.existsSync(filepath)) {
        throw new Error(`Lexasome file not found: ${filepath}`);
    }
    
    let selected;
    if (filepath.endsWith('.txt')) {
        selected = await selectFromTxt(filepath, count);
    } else if (filepath.endsWith('.csv')) {
        selected = await selectFromCsv(filepath, count);
    } else if (filepath.endsWith('.json')) {
        selected = await selectFromJson(filepath, jsonPath, count);
    } else {
        throw new Error(`Unsupported file type: ${path.extname(filepath)}`);
    }
    
    return {
        success: true,
        file: relativePath,
        count: selected.length,
        selected: selected.length === 1 ? selected[0] : selected,
        timestamp: new Date().toISOString()
    };
}

/**
 * Test function - run some sample selections
 */
async function runTests() {
    console.log('=== Sequon Selector Tests ===\n');
    
    const tests = [
        { path: 'domains/technology.txt', count: 1, description: 'Single technology domain' },
        { path: 'domains/creative.txt', count: 2, description: 'Two creative domains' },
        { path: 'constraints/style.csv', count: 1, description: 'Weighted style constraint' },
        { path: 'constraints/format.csv', count: 2, description: 'Two format constraints' },
        { path: 'models/models.json', count: 1, jsonPath: 'models', description: 'Random model' }
    ];
    
    for (const test of tests) {
        try {
            console.log(`Test: ${test.description}`);
            console.log(`Path: ${test.path}, Count: ${test.count}`);
            
            const result = await selectSequons(test.path, test.count, test.jsonPath);
            console.log('Result:', JSON.stringify(result, null, 2));
            console.log('---\n');
        } catch (error) {
            console.error(`Test failed: ${error.message}`);
            console.log('---\n');
        }
    }
    
    console.log('=== End of Tests ===');
}

// Command line interface
if (require.main === module) {
    const args = process.argv.slice(2);
    
    if (args.length === 0) {
        // Run tests if no arguments
        runTests().catch(console.error);
    } else if (args[0] === 'test') {
        runTests().catch(console.error);
    } else if (args.length >= 1) {
        // Parse arguments: path [count] [jsonPath]
        const relativePath = args[0];
        const count = args[1] ? parseInt(args[1]) : 1;
        const jsonPath = args[2] || '';
        
        selectSequons(relativePath, count, jsonPath)
            .then(result => {
                console.log(JSON.stringify(result, null, 2));
            })
            .catch(error => {
                console.error(JSON.stringify({
                    success: false,
                    error: error.message,
                    timestamp: new Date().toISOString()
                }, null, 2));
                process.exit(1);
            });
    }
}

// Export for use as module
module.exports = {
    selectSequons,
    selectFromTxt,
    selectFromCsv,
    selectFromJson,
    runTests
};
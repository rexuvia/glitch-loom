#!/usr/bin/env node
/**
 * Sequon Selector - Simple Phase 1 Implementation
 * No external dependencies
 */

const fs = require('fs');
const path = require('path');

// Base directory for lexasomes
const LEXASOME_BASE = path.join(__dirname, '..', 'lexasomes');

/**
 * Select random sequons from a text file
 */
function selectFromTxt(filepath, count = 1) {
    try {
        const content = fs.readFileSync(filepath, 'utf8');
        const lines = content.split('\n')
            .map(line => line.trim())
            .filter(line => line.length > 0 && !line.startsWith('#'));
        
        if (lines.length === 0) {
            throw new Error(`No sequons found in ${filepath}`);
        }
        
        // Simple random selection (with possible duplicates for now)
        const selected = [];
        for (let i = 0; i < count; i++) {
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
 * Select weighted sequons from a CSV file (simple parser)
 */
function selectFromCsv(filepath, count = 1) {
    try {
        const content = fs.readFileSync(filepath, 'utf8');
        const lines = content.split('\n')
            .map(line => line.trim())
            .filter(line => line.length > 0);
        
        if (lines.length < 2) { // Need header + at least one data row
            throw new Error(`Invalid CSV format in ${filepath}`);
        }
        
        // Parse header
        const headers = lines[0].split(',').map(h => h.trim());
        const constraintIndex = headers.indexOf('constraint');
        const weightIndex = headers.indexOf('weight');
        
        if (constraintIndex === -1 || weightIndex === -1) {
            throw new Error(`CSV missing 'constraint' or 'weight' columns in ${filepath}`);
        }
        
        // Parse data rows
        const sequons = [];
        const weights = [];
        
        for (let i = 1; i < lines.length; i++) {
            const cells = lines[i].split(',').map(c => c.trim());
            if (cells.length > Math.max(constraintIndex, weightIndex)) {
                sequons.push(cells[constraintIndex]);
                weights.push(parseFloat(cells[weightIndex]) || 0);
            }
        }
        
        if (sequons.length === 0) {
            throw new Error(`No data rows in CSV ${filepath}`);
        }
        
        // Weighted random selection (simple algorithm)
        const selected = [];
        for (let i = 0; i < count; i++) {
            const totalWeight = weights.reduce((a, b) => a + b, 0);
            let random = Math.random() * totalWeight;
            let cumulative = 0;
            
            for (let j = 0; j < sequons.length; j++) {
                cumulative += weights[j];
                if (random <= cumulative) {
                    selected.push(sequons[j]);
                    break;
                }
            }
        }
        
        return selected;
    } catch (error) {
        console.error(`Error reading CSV file ${filepath}:`, error.message);
        throw error;
    }
}

/**
 * Select from JSON file
 */
function selectFromJson(filepath, jsonPath = '', count = 1) {
    try {
        const content = fs.readFileSync(filepath, 'utf8');
        const data = JSON.parse(content);
        
        // Simple path resolution
        let targetArray;
        if (jsonPath === 'models') {
            targetArray = data.models || [];
        } else if (jsonPath === 'selection_rules') {
            return [data.selection_rules || {}];
        } else {
            // Try to find first array
            if (Array.isArray(data)) {
                targetArray = data;
            } else {
                for (const key in data) {
                    if (Array.isArray(data[key])) {
                        targetArray = data[key];
                        break;
                    }
                }
            }
            targetArray = targetArray || [];
        }
        
        if (!Array.isArray(targetArray) || targetArray.length === 0) {
            throw new Error(`No array found at path ${jsonPath} in ${filepath}`);
        }
        
        // Random selection
        const selected = [];
        for (let i = 0; i < count; i++) {
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
 */
function selectSequons(relativePath, count = 1, jsonPath = '') {
    const filepath = path.join(LEXASOME_BASE, relativePath);
    
    if (!fs.existsSync(filepath)) {
        throw new Error(`Lexasome file not found: ${filepath}`);
    }
    
    let selected;
    if (filepath.endsWith('.txt')) {
        selected = selectFromTxt(filepath, count);
    } else if (filepath.endsWith('.csv')) {
        selected = selectFromCsv(filepath, count);
    } else if (filepath.endsWith('.json')) {
        selected = selectFromJson(filepath, jsonPath, count);
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
 * Run demonstration tests
 */
function runDemo() {
    console.log('=== Phenosemantic Agentic Skill - Demo ===\n');
    console.log('Testing Sequon Selector Implementation\n');
    
    const demos = [
        { 
            path: 'domains/technology.txt', 
            count: 1, 
            title: '1. Random Technology Domain'
        },
        { 
            path: 'domains/creative.txt', 
            count: 2, 
            title: '2. Two Creative Domains' 
        },
        { 
            path: 'constraints/style.csv', 
            count: 1, 
            title: '3. Weighted Style Constraint' 
        },
        { 
            path: 'constraints/format.csv', 
            count: 1, 
            title: '4. Format Constraint' 
        },
        { 
            path: 'models/models.json', 
            count: 1, 
            jsonPath: 'models',
            title: '5. Random AI Model' 
        }
    ];
    
    for (const demo of demos) {
        console.log(`\n${demo.title}:`);
        console.log(`  File: ${demo.path}`);
        
        try {
            const result = selectSequons(demo.path, demo.count, demo.jsonPath || '');
            
            if (demo.path.includes('models.json')) {
                const model = result.selected;
                console.log(`  Selected: ${model.id} (${model.provider})`);
                console.log(`  Strengths: ${model.strengths.slice(0, 3).join(', ')}`);
                console.log(`  Cost: $${model.cost_per_1k_input}/1K input`);
            } else {
                console.log(`  Selected: ${JSON.stringify(result.selected)}`);
            }
            
        } catch (error) {
            console.log(`  Error: ${error.message}`);
        }
    }
    
    console.log('\n=== End of Demo ===\n');
    
    // Show what a complete generation might look like
    console.log('Sample Complete Generation:');
    console.log('---------------------------');
    
    try {
        // Simulate a complete selection
        const domain = selectSequons('domains/technology.txt', 1).selected;
        const task = selectSequons('tasks/analysis.txt', 1).selected;
        const style = selectSequons('constraints/style.csv', 1).selected;
        const format = selectSequons('constraints/format.csv', 1).selected;
        
        console.log(`Domain: ${domain}`);
        console.log(`Task: ${task}`);
        console.log(`Style: ${style}`);
        console.log(`Format: ${format}`);
        
        // Create a simple prompt
        const prompt = `Perform ${task} on "${domain}" with ${style} style in ${format} format.`;
        console.log(`\nGenerated Prompt:\n"${prompt}"`);
        
        // Select an appropriate model
        const models = selectSequons('models/models.json', 3, 'models').selected;
        const technicalModels = models.filter(m => 
            m.strengths && m.strengths.some(s => 
                ['technical', 'analysis', 'reasoning'].includes(s)
            )
        );
        
        if (technicalModels.length > 0) {
            const selectedModel = technicalModels[0];
            console.log(`\nRecommended Model: ${selectedModel.id}`);
            console.log(`Reason: Good for technical analysis (strengths: ${selectedModel.strengths.slice(0, 2).join(', ')})`);
        }
        
    } catch (error) {
        console.log(`Demo error: ${error.message}`);
    }
    
    console.log('\n=== Ready for OpenClaw Agent Integration ===');
}

// Command line interface
if (require.main === module) {
    const args = process.argv.slice(2);
    
    if (args.length === 0 || args[0] === 'demo') {
        runDemo();
    } else if (args[0] === 'select' && args.length >= 2) {
        const relativePath = args[1];
        const count = args[2] ? parseInt(args[2]) : 1;
        const jsonPath = args[3] || '';
        
        try {
            const result = selectSequons(relativePath, count, jsonPath);
            console.log(JSON.stringify(result, null, 2));
        } catch (error) {
            console.error(JSON.stringify({
                success: false,
                error: error.message,
                timestamp: new Date().toISOString()
            }, null, 2));
            process.exit(1);
        }
    } else {
        console.log('Usage:');
        console.log('  node sequon-selector-simple.js demo          # Run demonstration');
        console.log('  node sequon-selector-simple.js select <path> [count] [jsonPath]');
        console.log('\nExamples:');
        console.log('  node sequon-selector-simple.js select domains/technology.txt 2');
        console.log('  node sequon-selector-simple.js select constraints/style.csv 1');
        console.log('  node sequon-selector-simple.js select models/models.json 1 models');
    }
}

module.exports = {
    selectSequons,
    selectFromTxt,
    selectFromCsv,
    selectFromJson
};
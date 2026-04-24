#!/usr/bin/env node
/**
 * Template Filler - Simple Phase 1 Implementation
 * Fills lexaplast templates with selected sequons
 */

const fs = require('fs');
const path = require('path');

// Import the sequon selector
const { selectSequons } = require('./sequon-selector-simple');

// Base directories
const LEXAPLAST_BASE = path.join(__dirname, '..', 'lexaplasts');
const LEXASOME_BASE = path.join(__dirname, '..', 'lexasomes');

/**
 * Load a lexaplast template
 */
function loadTemplate(templateName) {
    const templatePath = path.join(LEXAPLAST_BASE, `${templateName}.json`);
    
    if (!fs.existsSync(templatePath)) {
        throw new Error(`Template not found: ${templatePath}`);
    }
    
    try {
        const content = fs.readFileSync(templatePath, 'utf8');
        return JSON.parse(content);
    } catch (error) {
        throw new Error(`Error parsing template ${templateName}: ${error.message}`);
    }
}

/**
 * Select model based on template rules and sequons
 */
function selectModel(template, sequons) {
    const modelSelection = template.model_selection;
    
    if (!modelSelection) {
        return 'sonnet'; // Default fallback
    }
    
    // Simple strategy implementation
    if (modelSelection.strategy === 'fixed') {
        return modelSelection.model;
    }
    
    if (modelSelection.strategy === 'task_based') {
        const task = sequons.task || '';
        
        // Simple task detection
        if (task.includes('technical') || task.includes('analysis')) {
            return modelSelection.rules?.technical_analysis || modelSelection.default || 'sonnet';
        }
        if (task.includes('creative') || task.includes('writing')) {
            return modelSelection.rules?.creative_analysis || modelSelection.default || 'sonnet';
        }
        
        return modelSelection.default || 'sonnet';
    }
    
    // Default fallback
    return 'sonnet';
}

/**
 * Fill a template with sequons
 */
function fillTemplate(templateName, overrides = {}) {
    const template = loadTemplate(templateName);
    
    // Collect all sequons
    const sequons = {};
    const errors = [];
    
    // Process each variable defined in template
    for (const [varName, varDef] of Object.entries(template.variables || {})) {
        if (overrides[varName]) {
            // Use override if provided
            sequons[varName] = overrides[varName];
            continue;
        }
        
        try {
            const source = varDef.source;
            const count = varDef.count || 1;
            
            // Select sequons
            const result = selectSequons(source, count);
            sequons[varName] = result.selected;
        } catch (error) {
            errors.push(`Variable ${varName}: ${error.message}`);
            sequons[varName] = `[ERROR: ${error.message}]`;
        }
    }
    
    // Fill the template
    let prompt = template.template;
    for (const [varName, value] of Object.entries(sequons)) {
        const placeholder = `{{${varName}}}`;
        const replacement = Array.isArray(value) ? value.join(', ') : value;
        prompt = prompt.replace(new RegExp(placeholder, 'g'), replacement);
    }
    
    // Select model
    const model = selectModel(template, sequons);
    
    // Prepare result
    const result = {
        id: `gen_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        timestamp: new Date().toISOString(),
        template: template.name,
        sequons,
        model,
        prompt,
        status: errors.length > 0 ? 'partial' : 'ready',
        errors: errors.length > 0 ? errors : undefined
    };
    
    return result;
}

/**
 * Run demonstration
 */
function runDemo() {
    console.log('=== Template Filler Demo ===\n');
    
    console.log('1. Testing basic-analysis template:\n');
    
    try {
        const result = fillTemplate('basic-analysis');
        
        console.log('Template:', result.template);
        console.log('Sequons:', JSON.stringify(result.sequons, null, 2));
        console.log('Selected Model:', result.model);
        console.log('\nGenerated Prompt:');
        console.log('-' .repeat(50));
        console.log(result.prompt);
        console.log('-' .repeat(50));
        console.log('\nStatus:', result.status);
        if (result.errors) {
            console.log('Errors:', result.errors);
        }
        
    } catch (error) {
        console.error('Error:', error.message);
    }
    
    console.log('\n\n2. Testing with overrides:\n');
    
    try {
        const overrides = {
            domain: 'artificial-intelligence',
            task: 'ethical-examination',
            style_constraint: 'detailed-explanation',
            format_constraint: 'structured-outline'
        };
        
        const result = fillTemplate('basic-analysis', overrides);
        
        console.log('Overrides applied:', JSON.stringify(overrides, null, 2));
        console.log('\nGenerated Prompt:');
        console.log('-' .repeat(50));
        console.log(result.prompt);
        console.log('-' .repeat(50));
        
    } catch (error) {
        console.error('Error:', error.message);
    }
    
    console.log('\n\n3. Sample workflow for OpenClaw integration:\n');
    
    console.log('Step 1: Fill template');
    console.log('Step 2: Send to selected model via sessions_spawn');
    console.log('Step 3: Capture response');
    console.log('Step 4: Auto-rank output');
    console.log('Step 5: Store in review queue');
    
    console.log('\nExample OpenClaw agent call:');
    console.log(`
sessions_spawn({
  task: result.prompt,
  label: 'phenosemantic-generation',
  model: result.model,
  runtime: 'subagent'
});
    `);
}

// Command line interface
if (require.main === module) {
    const args = process.argv.slice(2);
    
    if (args.length === 0 || args[0] === 'demo') {
        runDemo();
    } else if (args[0] === 'fill' && args.length >= 2) {
        const templateName = args[1];
        
        // Parse overrides from remaining args (simple key=value format)
        const overrides = {};
        for (let i = 2; i < args.length; i++) {
            const [key, value] = args[i].split('=');
            if (key && value) {
                overrides[key] = value;
            }
        }
        
        try {
            const result = fillTemplate(templateName, overrides);
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
        console.log('  node template-filler-simple.js demo');
        console.log('  node template-filler-simple.js fill <template> [key=value ...]');
        console.log('\nExamples:');
        console.log('  node template-filler-simple.js fill basic-analysis');
        console.log('  node template-filler-simple.js fill basic-analysis domain=quantum-computing');
    }
}

module.exports = {
    fillTemplate,
    loadTemplate,
    selectModel
};
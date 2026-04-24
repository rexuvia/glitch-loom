# MSPP with Keyword Approval Workflow

## Updated `mspp publish` Command Flow:

### Step 1: Parse command and load result
- Read the JSON file from `modelshow-private`
- Extract prompt and existing metadata

### Step 2: Generate suggested keywords
- Use an LLM subagent to generate 2-4 relevant keywords based on prompt/results
- Focus on content-specific terms, avoid generic "AI comparison" terms

### Step 3: Prompt for keyword approval
Send a message like:
```
📋 **Publishing: [Result ID]**

**Prompt:** [First 100 chars of prompt...]

**Suggested Keywords:** keyword1, keyword2, keyword3, keyword4

**Options:**
1. ✅ **Approve keywords** - Use as-is
2. ✏️ **Edit keywords** - Let me edit them
3. 🔄 **Regenerate keywords** - Generate new suggestions
4. ❌ **Cancel publish** - Don't publish this result

*Reply with 1-4 to choose.*
```

### Step 4: Handle user response
- **1 (Approve)**: Use suggested keywords
- **2 (Edit)**: Prompt "Please provide your edited keywords as a comma-separated list"
- **3 (Regenerate)**: Generate new keywords and repeat Step 3
- **4 (Cancel)**: Abort publishing for this result

### Step 5: Finalize publishing
- Inject approved keywords into result's JSON (`meta.keywords` list)
- Copy files to `modelshow-published/`
- Update web index
- Rebuild and deploy site

## Implementation Notes

1. **State Management**: Need to track which result is awaiting keyword approval
2. **Multiple Results**: For `mspp publish id1 id2 id3`, process sequentially with approval for each
3. **User Experience**: Clear prompts with all needed context
4. **Error Handling**: Graceful cancellation and recovery

## Example Conversation Flow

```
User: mspp publish give-me-a-percentage-chance-2026-03-16-1133

Assistant: 📋 **Publishing: give-me-a-percentage-chance-2026-03-16-1133**

**Prompt:** give me a percentage chance that we are living in a simulation...

**Suggested Keywords:** simulation theory, instruction following, response formatting, philosophical probability

**Options:**
1. ✅ Approve keywords
2. ✏️ Edit keywords  
3. 🔄 Regenerate keywords
4. ❌ Cancel publish

User: 2

Assistant: Please provide your edited keywords as a comma-separated list.

User: simulation theory, philosophical questions, percentage responses, ai instruction following

Assistant: ✅ Keywords updated. Publishing result...
[Proceeds with publishing steps]
```

## Benefits
- **User Control**: You can review and modify keywords before publication
- **Quality**: Ensures keywords are relevant and specific
- **Learning**: Over time, you can provide feedback that improves keyword generation
- **Consistency**: Maintains high-quality metadata across all published results
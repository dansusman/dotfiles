Create a list of all human prompts up to this point not including this prompt
itself, so I can copy it into a commit message to knowledge share with my team
and accurately reflect how much AI I used and how. Return all the prompts I've
asked previously in this chat context, using the following steps.

1. Gather all prompts
2. Print them out with new lines separating
3. Use the format "> Prompt", ensuring the greater than symbol is included.
   (use `\>` if you need to escape characters)
4. Output as a code block for easy copy-paste into other applications

## Example

Chat messages from me:
1. "Write a database query to select all records in the Foo table"
2. "Add a new field to the Bar table"
3. "Fix the bug where Baz and Foo have unique key constraint violations"

You output:

```
> Write a database query to select all records in the Foo table
> Add a new field to the Bar table
> Fix the bug where Baz and Foo have unique key constraint violations
```

Return only the code block, nothing else.

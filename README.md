# Shell Anonymizer

A lightweight CLI tool to anonymize sensitive terms in text files before sharing them with LLMs/Chatbots, and to deanonymize the responses afterwards.

## Features

- **Non-destructive**: Never modifies the original input files.
- **Deterministic**: Uses a property-based mapping for consistent replacements.
- **Simple Integration**: Easy to use in CI/CD pipelines or local workflows.

## Configuration (`mapping.properties`)

The tool requires a `mapping.properties` file in the same directory. Use the format `OriginalValue=Placeholder`. 

**Example Content:**
```properties
# Format: SensitiveValue=UniqueToken
Insuria=${ANON_PROJECT}
10.0.0.5=${ANON_IP_INTERNAL}
Customer-DB=${ANON_DB_SYSTEM}
John Doe=${ANON_USER_A}
```

## Usage

### 1. Anonymize your request
Replaces all original terms with the defined placeholders.
```bash
./anon.sh -a request.txt
# Generates: request.anon.txt
```

### 2. Deanonymize the response
Restores the original terms in the chatbot's answer.
```bash
./anon.sh -d chatbot_response.txt
# Generates: chatbot_response.deanon.txt
```

## Best Practices

* **Token Uniqueness**: Always use specific tokens like `${TOKEN_NAME}` to prevent accidental replacements of common words during the deanonymization phase (e.g., using "Project" might replace every instance of that word in the chatbot's generic advice).
* **Case Sensitivity**: The replacement is case-sensitive. `Insuria` will not match `insuria`. Ensure your properties file reflects the casing used in your documents.
* **Safety**: Even with anonymization, avoid pasting highly sensitive credentials or production secrets into third-party LLMs.

## Technical Notes

- Uses `sed` with `|` as a delimiter to allow slashes (e.g., in URLs or file paths) within the mapping values.
- Implements a multi-pass replacement strategy.

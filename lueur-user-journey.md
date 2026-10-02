```mermaid
flowchart TD
    A(["App launch"]) --> B["Splash"]
    B --> C{"Signed in?"}
    C -->|Yes| H["Home"]
    C -->|No| D{"Seen onboarding?"}
    D -->|No| ON["Onboarding"]
    D -->|Yes| E{"Signed in before on this device?"}
    ON --> E
    E -->|Never| RG["Register"]
    E -->|Before| LG["Login"]

    LG -->|Forgot password| FP["Forgot password"]
    FP --> LG
    RG -->|Continue as guest| GS["Guest session"]
    LG -->|Continue as guest, after a warning| GS
    GS --> H

    RG --> AG{"Which account?"}
    LG --> AG
    AG -->|New, email| CB["18+ checkbox on Register"]
    AG -->|New, Google| MD["18+ modal, declining deletes the account"]
    AG -->|Returning| H
    CB --> H
    MD --> H

    H --> MI["Pick a mood and write a few words"]
    MI --> MC["Mood choice dialog"]
    MC --> AF["Affirmation card"]
    AF -->|Talk to Luna| RS["Luna's reply"]
    AF -->|Breathe| BR["Guided breathing"]
    AF -->|Draw| DR["Free draw"]
    AF -->|Sudoku| SU["Sudoku"]

    RS -->|Guest| GB["Sign in to hear from Luna"]
    RS -->|Bookmark| SQ["Saved quotes"]
    RS -->|Talk again| CH["Chat with Luna"]
    BR -->|Talk to Luna| CH
    DR -->|Talk to Luna| CH
    CH -->|Session ends| JE["Entry saved to the journal"]

    RS -->|Entry saved| JR["Journal tab"]
    JE --> JR
    BR -->|Activity logged| JR
    DR -->|Activity logged| JR
    SU -->|Activity logged| JR

    H -->|See all| TL["Timeline"]
    JR --> TL
    JR --> WL["Weekly letter"]
    JR --> SC["Streak celebration"]
    TL -->|Open a day| CH

    H -.->|Bottom nav| JR
    JR -.->|Bottom nav| PF["Profile tab"]
    PF --> SQ
    PF --> DV["Saved drawings viewer"]
    PF --> SH["Sudoku history"]
    PF --> ST["Theme and language"]
    PF --> DE["Delete journal entries or account"]
    PF --> LO["Log out"]
    LO --> LG

    style A fill:#FFD4B8,stroke:#E8825A,color:#3A2A1E
    style H fill:#C8B4F8,stroke:#6E59C5,color:#3A2A1E
    style RS fill:#E8825A,stroke:#B23A0A,color:#fff
    style BR fill:#5BBFA0,stroke:#2E7D5F,color:#fff
    style DR fill:#FFD4B8,stroke:#E8825A,color:#3A2A1E
    style SU fill:#C8B4F8,stroke:#6E59C5,color:#3A2A1E
    style JR fill:#FFF8F5,stroke:#8C6A52,color:#3A2A1E
    style PF fill:#FFF8F5,stroke:#8C6A52,color:#3A2A1E
```

> **Chat ending:** when a chat ends, the backend saves the session as a journal entry and the app shows the "saved to your journal" card. The one exception is a fallback reply (when Luna can't answer): it is never saved, never shows that card, and never reaches the Journal or Saved quotes.

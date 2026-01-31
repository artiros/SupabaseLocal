-- Enable the pgvector extension to work with embedding vectors
create extension if not exists vector;

-- Create a table to store your documents
create table if not exists documents (
  id bigserial primary key,
  content text, -- corresponds to Document.pageContent
  metadata jsonb, -- corresponds to Document.metadata
  embedding vector(384) -- 384 dimensions for all-MiniLM-L6-v2
);

-- Associate with user (optional, if you want per-user knowledge base)
-- For now, let's keep it global or add a user_id if needed. The prompt implied generic knowledge.
-- But if we want to store user specific notes, we might need user_id. 
-- Let's add user_id but make it nullable for "global" docs.
alter table documents add column if not exists user_id uuid references auth.users(id);

-- Enable RLS
alter table documents enable row level security;

-- Policies
create policy "Users can read all documents" on documents for select using (true);
create policy "Users can insert their own documents" on documents for insert with check (auth.uid() = user_id);

-- Create a function to search for documents
create or replace function match_documents (
  query_embedding vector(384),
  match_threshold float,
  match_count int
)
returns table (
  id bigint,
  content text,
  metadata jsonb,
  similarity float
)
language plpgsql
as $$
begin
  return query
  select
    documents.id,
    documents.content,
    documents.metadata,
    1 - (documents.embedding <=> query_embedding) as similarity
  from documents
  where 1 - (documents.embedding <=> query_embedding) > match_threshold
  order by documents.embedding <=> query_embedding
  limit match_count;
end;
$$;

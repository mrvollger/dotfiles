def get_mem_mb(wildcards, attempt):
    """Scale memory with retries: 8 GB per attempt, doubling past attempt 3."""
    if attempt < 3:
        return attempt * 1024 * 8
    return attempt * 1024 * 16

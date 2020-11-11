# -*- coding: utf-8 -*-


def quote_redis_conf_argument(text):
    """
    Escapes and quotes given text to make it safe for usage as an argument
    in the Redis configuration file.

    Refer to https://redis.io/topics/config and
    https://github.com/redis/redis/blob/unstable/src/sds.c
    """
    if text is None:
        return text
    escaped = str(text) \
        .replace('\\', '\\\\') \
        .replace('\r', '\\r') \
        .replace('\n', '\\n') \
        .replace('"', '\\"')
    return '"' + escaped + '"'

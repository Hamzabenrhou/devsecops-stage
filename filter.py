def alertFilter(alert):
    ignore_ids = [10023, 90022]
    if int(alert.getPluginId()) in ignore_ids:
        return False  # Ignore this alert
    return True  # Keep all others

<script lang="ts">
  import { onMount } from 'svelte';
  import ReconnectingWebSocket from 'reconnecting-websocket';

  const enum Status {
    Connecting,
    Active,
    Closed,
  }

  let status: Status = Status.Connecting;
  let logMessages: string[] = [];

  const showStatus: Record<Status, string> = {
    [Status.Connecting]: 'connecting',
    [Status.Active]: 'active',
    [Status.Closed]: 'closed',
  };

  onMount(() => {
    const ws = new ReconnectingWebSocket('ws://127.0.0.1:8149/ws');

    ws.addEventListener('open', (ev) => {
      status = Status.Active;
      console.log('opened');
    });

    ws.addEventListener('message', (event) => {
      logMessages = [...logMessages, event.data];
    });

    ws.addEventListener('close', (ev) => {
      status = Status.Closed;
      console.log('closed');
    });

    return () => {
      ws.close();
    };
  });
</script>

<div>
  status: {showStatus[status]}
</div>

<ul class="messages">
  {#each logMessages as msg}
    <li>{msg}</li>
  {/each}
</ul>

<style lang="postcss">
  .messages {
    font-family: monospace;
  }
</style>

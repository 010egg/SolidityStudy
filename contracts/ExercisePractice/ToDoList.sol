// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoList {
    struct Task {
        string name;
        bool completed;
    }

    Task[] public tasks;

    // 事件声明
    event TaskCreated(uint taskId, string name);
    event TaskUpdated(uint taskId, string name);
    event TaskStatusToggled(uint taskId, bool completed);
    event TaskStatusSet(uint taskId, bool completed);


    // 创建任务
    function createTask(string memory _name) public {
        tasks.push(Task(_name, false));
        emit TaskCreated(tasks.length - 1, _name);
    }

    // 修改任务名称
    function updateTaskName(uint _taskId, string memory _newName) public {
        require(_taskId < tasks.length, "Task does not exist.");
        tasks[_taskId].name = _newName;
        emit TaskUpdated(_taskId, _newName);
    }
        // 手动设置完成状态为已完成
    function setCompleted(uint _taskId) public {
        require(_taskId < tasks.length, "Task does not exist.");
        tasks[_taskId].completed = true;
        emit TaskStatusSet(_taskId, true);
    }

    // 手动设置完成状态为未完成
    function setNotCompleted(uint _taskId) public {
        require(_taskId < tasks.length, "Task does not exist.");
        tasks[_taskId].completed = false;
        emit TaskStatusSet(_taskId, false);
    }

    // 手动切换完成状态
    function toggleCompletion(uint _taskId) public {
        require(_taskId < tasks.length, "Task does not exist.");
        tasks[_taskId].completed = !tasks[_taskId].completed;
        emit TaskStatusToggled(_taskId, tasks[_taskId].completed);
    }

    // 获取任务信息
    function getTask(uint _taskId) public view returns (string memory name, bool completed) {
        require(_taskId < tasks.length, "Task does not exist.");
        Task memory task = tasks[_taskId];
        return (task.name, task.completed);
    }

    // 获取所有任务数量
    function getTasksCount() public view returns (uint) {
        return tasks.length;
    }
}
